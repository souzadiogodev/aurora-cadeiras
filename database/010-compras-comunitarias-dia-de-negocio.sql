-- 010-compras-comunitarias-dia-de-negocio.sql
-- O relatório de compras de comunidades tradicionais passa a agrupar pelo mês de Brasília (UTC-3), como o resto do
-- sistema (A81, 008). Antes, um recebimento entre 21h e 24h do último dia do mês caía no mês seguinte.
-- O 002 não é alterado: scripts já aplicados são imutáveis (CLAUDE.md). ALTER VIEW mantém as permissões (005).
GO

ALTER VIEW dbo.vw_ComprasComunidadesTradicionais AS
WITH Recebimentos AS (
    SELECT
        YEAR(DATEADD(HOUR, -3, m.DataHora))  AS Ano,
        MONTH(DATEADD(HOUR, -3, m.DataHora)) AS Mes,
        f.ComunidadeTradicional,
        m.Quantidade * pci.CustoUnitario AS Valor
    FROM dbo.MovimentoEstoque m
    JOIN dbo.PedidoCompraItem pci ON pci.PedidoCompraId = m.OrigemId AND pci.MateriaPrimaId = m.MateriaPrimaId
    JOIN dbo.PedidoCompra pc      ON pc.PedidoCompraId = pci.PedidoCompraId
    JOIN dbo.Fornecedor f         ON f.FornecedorId = pc.FornecedorId
    WHERE m.Origem = 'Compra'
)
SELECT
    Ano,
    Mes,
    CAST(SUM(CASE WHEN ComunidadeTradicional = 1 THEN Valor ELSE 0 END) AS decimal(14,2)) AS ValorComunidades,
    CAST(SUM(Valor) AS decimal(14,2)) AS ValorTotal,
    CAST(CASE WHEN SUM(Valor) = 0 THEN 0
              ELSE 100.0 * SUM(CASE WHEN ComunidadeTradicional = 1 THEN Valor ELSE 0 END) / SUM(Valor) END AS decimal(5,2)) AS PercentualComunidades
FROM Recebimentos
GROUP BY Ano, Mes;
GO
