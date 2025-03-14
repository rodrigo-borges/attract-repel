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
- [ ] Ser alertado quando uma criatura exibe determinado gene.
- [x] Visualizar detalhes de criaturas que já morreram. (2025-03-13)
- [ ] Comparar genes entre duas criaturas.
- [x] Escolher o número de gerações na árvore genealógica. (2025-03-14)
- [ ] Controlar o zoom da árvore genealógica.
- [ ] Marcar criaturas mortas e seus descendentes.
- [x] Visualizar a quantidade de descendentes vivos de cada criatura. (2025-03-14)
- [ ] Visualizar marcadores na árvore genealógica.
- [ ] Visualizar a geração das criaturas.

### Simulação

- [ ] Agressão entre criaturas similar à atração.
- [ ] Tempo de incubação, em que a criatura nasce, mas ainda não é detectada nem detecta outras entidades.
- [ ] Custo de energia proporcional ao tamanho do campo de visão.
- [ ] Variação no tamanho das criaturas.
- [ ] Inclusão de massa no cálculo de atração/repulsão.

### Problemas

- [ ] Quando o jogo está pausado, o controle de zoom e movimento da câmera pelas setas não funciona, mas o movimento pelo mouse continua funcionando. O motivo é o uso do `Engine.time_scale = 0.` para controle de pausa, pois `get_tree().paused` estava impedindo interações com a UI.