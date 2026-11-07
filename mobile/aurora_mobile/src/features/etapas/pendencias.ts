import type { EtapaDaEstacao, EtapaNaTela, StatusDaEtapa } from '@/features/etapas/tipos';
import type { ApontamentoPendente, TipoDeApontamento } from '@/features/sync/tipos';

/** O início deixa a etapa em andamento e o fim a conclui (o que o servidor fará ao receber o apontamento). */
export function statusAposApontamento(tipo: TipoDeApontamento): StatusDaEtapa {
  return tipo === 'Inicio' ? 'EmAndamento' : 'Concluida';
}

/**
 * Sobrepõe ao dado do servidor o que o operador já fez e ainda não foi enviado, para a tela refletir o toque na hora
 * (docs/08 §5, passo 1). Vale o último apontamento de cada etapa, pela hora do aparelho. Item rejeitado não entra:
 * o servidor recusou, então a etapa continua como o servidor a conhece.
 */
export function aplicarPendencias(
  etapas: readonly EtapaDaEstacao[],
  ativos: readonly ApontamentoPendente[],
): EtapaNaTela[] {
  const ultimoPorEtapa = new Map<number, ApontamentoPendente>();
  for (const item of [...ativos].sort((a, b) => a.dataHoraCliente.localeCompare(b.dataHoraCliente))) {
    ultimoPorEtapa.set(item.etapaId, item);
  }

  return etapas.map((etapa) => {
    const pendente = ultimoPorEtapa.get(etapa.etapaId);
    if (!pendente) return { ...etapa, pendenteEnvio: false };
    const status = statusAposApontamento(pendente.tipo);
    const iniciadaEm = pendente.tipo === 'Inicio' ? (etapa.iniciadaEm ?? pendente.dataHoraCliente) : etapa.iniciadaEm;
    return { ...etapa, status, iniciadaEm, pendenteEnvio: true };
  });
}

/** Etapas que ainda precisam de ação na estação: a concluída (inclusive a que só o aparelho sabe) sai da lista. */
export function etapasAbertas(etapas: readonly EtapaNaTela[]): EtapaNaTela[] {
  return etapas.filter((e) => e.status !== 'Concluida');
}
