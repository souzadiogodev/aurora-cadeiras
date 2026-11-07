namespace Aurora.Web.Api;

// Situações como a API as devolve (nome dos enums do domínio). O painel não referencia o domínio (só fala HTTP com a
// API), então os valores ficam aqui, num único lugar, em vez de espalhados pelas telas e regras.

public static class SituacaoDoPedido
{
    public const string Aberto = "Aberto";
    public const string Confirmado = "Confirmado";
    public const string EmProducao = "EmProducao";
    public const string Pronto = "Pronto";
    public const string Expedido = "Expedido";
    public const string Cancelado = "Cancelado";

    public static IReadOnlyList<string> Todas { get; } = [Aberto, Confirmado, EmProducao, Pronto, Expedido, Cancelado];
}

public static class SituacaoDaOrdem
{
    public const string Planejada = "Planejada";
    public const string EmAndamento = "EmAndamento";
    public const string Concluida = "Concluida";
    public const string Cancelada = "Cancelada";

    public static IReadOnlyList<string> Todas { get; } = [Planejada, EmAndamento, Concluida, Cancelada];
}

public static class SituacaoDaEtapa
{
    public const string Pendente = "Pendente";
    public const string EmAndamento = "EmAndamento";
    public const string Concluida = "Concluida";
}

public static class SituacaoDaCompra
{
    public const string Solicitado = "Solicitado";
    public const string Emitido = "Emitido";
    public const string ParcialmenteRecebido = "ParcialmenteRecebido";
    public const string Recebido = "Recebido";
    public const string Cancelado = "Cancelado";

    public static IReadOnlyList<string> Todas { get; } = [Solicitado, Emitido, ParcialmenteRecebido, Recebido, Cancelado];
}

public static class ResultadoDaInspecao
{
    public const string Aprovada = "Aprovada";
    public const string Reprovada = "Reprovada";
}
