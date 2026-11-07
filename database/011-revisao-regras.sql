-- 011-revisao-regras.sql
-- Revisão das regras de negócio (07/11/2026, A83).
-- sp_FinalizarEtapa não conferia o status da OP: com o pedido cancelado, uma etapa que já estava em andamento ainda
-- podia ser finalizada (pelo app ou pela sincronização offline). Agora OP cancelada ou concluída recusa o fim da
-- etapa com 51005, como já fazem o início e a inspeção. O resto da procedure é o do 007.
-- O 003 e o 007 não são alterados: scripts já aplicados são imutáveis (CLAUDE.md).
GO

ALTER PROCEDURE dbo.sp_FinalizarEtapa
    @OrdemProducaoEtapaId int,
    @ClientRequestId      uniqueidentifier,
    @DataHoraCliente      datetime2(0)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @dono bit = IIF(@@TRANCOUNT = 0, 1, 0);
    DECLARE @UsuarioId int = TRY_CAST(SESSION_CONTEXT(N'UsuarioId') AS int);

    BEGIN TRY
        IF @UsuarioId IS NULL THROW 51010, N'Usuário não definido no contexto da sessão.', 1;
        IF @dono = 1 BEGIN TRAN;

        IF EXISTS (SELECT 1 FROM dbo.ApontamentoProducao WHERE ClientRequestId = @ClientRequestId)
        BEGIN
            IF @dono = 1 COMMIT;
            RETURN;
        END;

        DECLARE @Status varchar(12), @EstacaoNome varchar(40), @OpStatus varchar(12);
        SELECT @Status = e.Status, @EstacaoNome = es.Nome, @OpStatus = op.Status
          FROM dbo.OrdemProducaoEtapa e WITH (UPDLOCK, ROWLOCK)
          JOIN dbo.EstacaoProducao es ON es.EstacaoId = e.EstacaoId
          JOIN dbo.OrdemProducao op   ON op.OrdemProducaoId = e.OrdemProducaoId
         WHERE e.OrdemProducaoEtapaId = @OrdemProducaoEtapaId;

        -- Reenvio simultâneo: quem esperava o lock da etapa encontra o apontamento gravado pelo vencedor
        IF EXISTS (SELECT 1 FROM dbo.ApontamentoProducao WHERE ClientRequestId = @ClientRequestId)
        BEGIN
            IF @dono = 1 COMMIT;
            RETURN;
        END;

        IF @Status IS NULL THROW 51008, N'Etapa não encontrada.', 1;
        IF @OpStatus IN ('Concluida', 'Cancelada')
            THROW 51005, N'A ordem de produção foi cancelada ou concluída e não aceita apontamentos.', 1;
        IF @Status <> 'EmAndamento' THROW 51005, N'A etapa não está em andamento.', 1;
        IF @EstacaoNome = 'Qualidade'
            THROW 51005, N'A etapa de Qualidade só é concluída por inspeção.', 1;

        UPDATE dbo.OrdemProducaoEtapa
           SET Status = 'Concluida', ConcluidaEm = SYSUTCDATETIME()
         WHERE OrdemProducaoEtapaId = @OrdemProducaoEtapaId;

        INSERT dbo.ApontamentoProducao (OrdemProducaoEtapaId, Tipo, UsuarioId, DataHoraCliente, ClientRequestId)
        VALUES (@OrdemProducaoEtapaId, 'Fim', @UsuarioId, @DataHoraCliente, @ClientRequestId);

        IF @dono = 1 COMMIT;
    END TRY
    BEGIN CATCH
        IF @dono = 1 AND @@TRANCOUNT > 0 ROLLBACK;
        IF @dono = 1 AND ERROR_NUMBER() IN (2601, 2627)
           AND EXISTS (SELECT 1 FROM dbo.ApontamentoProducao WHERE ClientRequestId = @ClientRequestId) RETURN;
        THROW;
    END CATCH
END;
GO
