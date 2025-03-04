# attract-repel
Aquário de criaturas que são atraídas ou repelidas por cores

## Problemas conhecidos

- Quando o jogo está pausado, o controle de zoom e movimento da câmera pelas setas não funciona, mas o movimento pelo mouse continua funcionando. O motivo é o uso do `Engine.time_scale = 0.` para controle de pausa, pois `get_tree().paused` estava impedindo interações com a UI.