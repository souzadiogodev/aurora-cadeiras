using Aurora.Application.Abstracoes;
using Aurora.Domain.Entidades;
using Aurora.Domain.Enums;
using Aurora.Domain.Excecoes;

namespace Aurora.Application.Produtos;

/// <summary>Busca de produto usada pelos serviços de produto, ficha técnica e roteiro, com o mesmo erro de "não encontrado".</summary>
public static class ProdutoRepositoryExtensions
{
    public static async Task<Produto> ObterOuFalharAsync(this IProdutoRepository produtos, int id, CancellationToken ct = default) =>
        await produtos.ObterPorIdAsync(id, ct)
        ?? throw new RegraDeNegocioException("PRODUTO_NAO_ENCONTRADO", "Produto não encontrado.", TipoErro.NaoEncontrado);
}
