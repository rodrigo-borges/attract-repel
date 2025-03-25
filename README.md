# attract-repel
Aquário de criaturas que são atraídas ou repelidas por cores

## Roadmap

Lista de implementações desejadas, sem ordem específica.

### Experiência

- [x] Seguir criatura selecionada com a câmera. (2025-03-12)
- [ ] Destacar janela com câmera seguindo criatura.
- [x] Adicionar marcador em uma criatura que será passado para seus descendentes. (2025-03-10)
- [ ] Visualizar métricas agrupadas por marcador.
- [x] Colidir e quicar criaturas com obstáculos genéricos. (2025-03-21)
- [x] Barrar visão das criaturas em obstáculos. (2025-03-21)
- [ ] Alterar atributos da criatura selecionada.
- [ ] Visualizar relação de criaturas ordenadas por desempenho.
- [x] Limitar nascimento inicial a spawners de criaturas. (2025-03-20)
- [x] Variar surgimento de comida baseado em parâmetros. (2025-03-20)
- [x] Mover e deformar elementos do mundo. (2025-03-24)
- [x] Deletar elementos do mundo. (2025-03-24)
- [ ] Duplicar elementos do mundo.
- [x] Criar obstáculos. (2025-03-25)
- [ ] Alterar configurações de nascedouros.
- [x] Criar comedouros. (2025-03-25)
- [x] Alterar configurações de comedouros. (2025-03-25)
- [ ] Criar comedouros.
- [ ] Finalizar simulação em caso de extinção.
- [ ] Finalizar simulação através de um botão.
- [ ] Exibir estatísticas ao finalizar simulação.
- [x] Migrar para Godot 4.4. (2025-03-13)
- [x] Selecionar rapidamente o pai da criatura selecionada. (2025-03-12)
- [x] Navegar pela genealogia de uma criatura. (2025-03-13)
- [ ] Visualizar detalhes da comida.
- [x] Marcar opcionalmente todos os descendentes da criatura junto dela. (2025-03-12)
- [x] Visualizar força e LoS apenas da criatura selecionada. (2025-03-12)
- [ ] Ser alertado quando uma criatura exibe determinado padrão de gene.
- [x] Visualizar detalhes de criaturas que já morreram. (2025-03-13)
- [x] Comparar genes entre duas criaturas. (2025-03-17)
- [x] Escolher o número de gerações na árvore genealógica. (2025-03-14)
- [x] Controlar o zoom da árvore genealógica. (2025-03-14)
- [x] Marcar criaturas mortas e seus descendentes. (2025-03-14)
- [x] Visualizar a quantidade de descendentes vivos de cada criatura. (2025-03-14)
- [x] Visualizar marcadores na árvore genealógica. (2025-03-14)
- [x] Visualizar a geração das criaturas. (2025-03-14)
- [x] Ocultar ramificações extintas da árvore. (2025-03-14)
- [ ] Visualizar distribuição de consumo de energia das criaturas.
- [ ] Visualizar histórico de mutações ao longo das gerações.

### Simulação

- [x] Agressão entre criaturas similar à atração. (2025-03-18)
- [x] Tempo de incubação, em que a criatura nasce, mas ainda não é detectada nem detecta outras entidades. (2025-03-18)
- [x] Custo de energia proporcional ao tamanho do campo de visão. (2025-03-17)
- [x] Variação no tamanho das criaturas. (2025-03-17)
- [x] ~~Inclusão de massa no cálculo de atração/repulsão. (2025-03-17)~~ Removido por aumentar a complexidade da estrutura da comida sem ganhos aparentes para a evolução. (2025-03-18)

### Problemas

- [x] Quando o jogo está pausado, o controle de zoom e movimento da câmera pelas setas não funciona, mas o movimento pelo mouse continua funcionando. O motivo é o uso do `Engine.time_scale = 0.` para controle de pausa, pois `get_tree().paused` estava impedindo interações com a UI. (2025-03-14)
- [x] Toda atualização na árvore genealógica remove o hover do mouse, interrompendo a análise visual. (2025-03-17)
- [x] O dropdown de marcadores está mostrando a lista duplicada, sendo que clicar em uma opção da segunda metade lança erro de posição fora da lista. (2025-03-18)
- [ ] Algumas colisões com comida não estão sendo processadas, de forma que a criatura fica parada escorada na comida.
- [ ] Depois de algumas dezenas de gerações, a árvore genealógica está travando o jogo e causando crashes (só aparentemente, porque não é lançado nenhum erro). Redesenhar toda a árvore em todo evento de nascimento ou morte, especificamente com a chamada de `get_descendents()`, é o maior gargalo de desempenho segundo o profiler.