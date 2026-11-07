namespace Aurora.Web.Extensions;

/// <summary>
/// A API manda horários em UTC e o negócio vive em Brasília (A81). O deslocamento é fixo (UTC-3, sem horário de verão
/// desde 2019) porque o contêiner não traz o banco de fusos e não depende do fuso do servidor: com ToLocalTime() o
/// painel mostrava a hora UTC quando rodava em contêiner.
/// </summary>
public static class HorarioDeBrasilia
{
    public static readonly TimeSpan Deslocamento = TimeSpan.FromHours(-3);

    /// <summary>Converte um horário UTC da API (com ou sem o "Kind" preenchido) para o horário de Brasília.</summary>
    public static DateTime De(DateTime utc) => DateTime.SpecifyKind(utc, DateTimeKind.Unspecified).Add(Deslocamento);

    public static DateTimeOffset Agora(TimeProvider relogio) => relogio.GetUtcNow().ToOffset(Deslocamento);
}
