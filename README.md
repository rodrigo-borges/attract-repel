# attract-repel
Aquário de criaturas que são atraídas ou repelidas por cores

## Roadmap

- [ ] Seguir criatura selecionada com a câmera.
- [ ] Destacar janela com câmera seguindo criatura.
- [x] Adicionar marcador em uma criatura que será passado para seus descendentes.
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
- [ ] Migrar para Godot 4.4.

## Problemas conhecidos

- Quando o jogo está pausado, o controle de zoom e movimento da câmera pelas setas não funciona, mas o movimento pelo mouse continua funcionando. O motivo é o uso do `Engine.time_scale = 0.` para controle de pausa, pois `get_tree().paused` estava impedindo interações com a UI.