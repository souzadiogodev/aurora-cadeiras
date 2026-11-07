using System.Linq.Expressions;
using Aurora.Application.Comum;

namespace Aurora.Infrastructure.Persistencia;

/// <summary>
/// Filtro "de/até" por dias de Brasília sobre um horário gravado em UTC (A82). Um único lugar para a regra: o dia
/// <c>de</c> começa às 00:00 de Brasília e o dia <c>ate</c> entra inteiro, até as 00:00 do dia seguinte.
/// </summary>
internal static class FiltroPorPeriodo
{
    public static IQueryable<T> NoPeriodo<T>(
        this IQueryable<T> consulta, Expression<Func<T, DateTime>> momento, DateOnly? de, DateOnly? ate)
    {
        if (de is DateOnly inicio)
        {
            consulta = consulta.Where(Comparar(momento, ExpressionType.GreaterThanOrEqual, DiaDeNegocio.InicioEmUtc(inicio)));
        }

        if (ate is DateOnly fim)
        {
            consulta = consulta.Where(Comparar(momento, ExpressionType.LessThan, DiaDeNegocio.InicioEmUtc(fim.AddDays(1))));
        }

        return consulta;
    }

    /// <summary>Monta <c>momento OP limite</c>; o limite vai como parâmetro do SQL, e não como literal no texto.</summary>
    private static Expression<Func<T, bool>> Comparar<T>(Expression<Func<T, DateTime>> momento, ExpressionType operador, DateTime limite)
    {
        var parametro = Expression.Property(Expression.Constant(new Limite(limite)), nameof(Limite.Valor));
        return Expression.Lambda<Func<T, bool>>(Expression.MakeBinary(operador, momento.Body, parametro), momento.Parameters);
    }

    private sealed record Limite(DateTime Valor);
}
