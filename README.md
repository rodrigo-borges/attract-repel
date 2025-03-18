# attract-repel
Aquário de criaturas que são atraídas ou repelidas por cores

## Roadmap

Lista de implementações desejadas, sem ordem específica.

### Experiência

- [x] Seguir criatura selecionada com a câmera. (2025-03-12)
- [ ] Destacar janela com câmera seguindo criatura.
- [x] Adicionar marcador em uma criatura que será passado para seus descendentes. (2025-03-10)
- [ ] Visualizar métricas agrupadas por marcador.
- [ ] Colidir e quicar criaturas com obstáculos genéricos.
- [ ] Barrar visão das criaturas em obstáculos.
- [ ] Alterar atributos da criatura selecionada.
- [ ] Visualizar relação de criaturas ordenadas por desempenho.
- [ ] Limitar nascimento inicial a spawners de criaturas.
- [ ] Variar surgimento de comida baseado em parâmetros.
- [ ] Adicionar, remover e editar obstáculos.
- [ ] Adicionar, remover e editar spawners de comida.
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

- [ ] Agressão entre criaturas similar à atração.
- [x] Tempo de incubação, em que a criatura nasce, mas ainda não é detectada nem detecta outras entidades. (2025-03-18)
- [x] Custo de energia proporcional ao tamanho do campo de visão. (2025-03-17)
- [x] Variação no tamanho das criaturas. (2025-03-17)
- [x] ~~Inclusão de massa no cálculo de atração/repulsão. (2025-03-17)~~ Removido por aumentar a complexidade da estrutura da comida sem ganhos aparentes para a evolução. (2025-03-18)

### Problemas

- [x] Quando o jogo está pausado, o controle de zoom e movimento da câmera pelas setas não funciona, mas o movimento pelo mouse continua funcionando. O motivo é o uso do `Engine.time_scale = 0.` para controle de pausa, pois `get_tree().paused` estava impedindo interações com a UI. (2025-03-14)
- [x] Toda atualização na árvore genealógica remove o hover do mouse, interrompendo a análise visual. (2025-03-17)
- [x] O dropdown de marcadores está mostrando a lista duplicada, sendo que clicar em uma opção da segunda metade lança erro de posição fora da lista. (2025-03-18)
- [ ] Algumas colisões com comidas não estão sendo processadas, com a criatura ficando parada escorada na comida.