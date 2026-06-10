# Sprints - Slime Elastico

Este arquivo transforma o GDD em uma sequencia pratica de desenvolvimento.
O foco inicial e validar se a mecanica principal e divertida antes de investir
em polimento, conteudo extra ou sistemas grandes.

## Progresso atual

Ultima atualizacao: prototipo jogavel com movimento, ricochete, coleta,
perigo, restart, fases manuais e suporte a multiplas frutas por fase.

Concluido:

- Sprint 1: movimento basico do slime;
- Sprint 2: paredes e ricochete;
- Sprint 3: coleta de fruta com sinal;
- Sprint 4: perigo, game over e restart;
- Sprint 5: carregamento de fases manuais;
- Sprint 6, parte 1: multiplas frutas por fase e troca de fase apos coletar todas.

Em andamento:

- Sprint 6, parte 2: contar frutas coletadas no mesmo lancamento e aplicar
  bonus simples.

Decisoes registradas:

- fases ficam em `res://levels/`;
- `Main` controla fluxo da partida e carregamento de fases;
- `Slime` fica fora das cenas de fase e e reposicionado por `SlimeStart`;
- cada fase usa um container `Fruits` para permitir multiplas frutas;
- frutas e espinhos emitem sinais; `Main` decide pontuacao, troca de fase e game over.

## Decisoes atuais de design

### Visao do jogo

A recomendacao para o prototipo e usar **2D com visao de cima**.

Motivos:

- combina melhor com arena fechada e quique em paredes;
- deixa a mira mais legivel para mouse e toque;
- evita gravidade, plataforma e problemas de chao que aumentariam o escopo;
- facilita criar fases manuais como pequenos desafios de angulo;
- favorece partidas curtas de score attack e puzzle arcade.

Visao lateral so faria mais sentido se o jogo virasse algo mais proximo de
plataforma, arremesso com gravidade ou Angry Birds. Para o objetivo atual,
isso adicionaria complexidade antes de sabermos se o core loop funciona.

### Estrutura de fases

Inicialmente, as fases serao **manuais**, nao geradas proceduralmente.

Motivos:

- permite desenhar desafios de mira intencionais;
- facilita testar se bater na parede e uma estrategia interessante;
- reduz bugs de spawn injusto;
- ajuda o jogador iniciante a aprender por situacoes controladas;
- deixa a dificuldade mais facil de revisar.

O score attack com spawn aleatorio pode voltar depois, quando a mecanica
principal estiver validada.

### Uso estrategico das paredes

Bater na parede deve ser uma estrategia, nao apenas acidente.

O design das primeiras fases deve testar:

- frutas em linha reta;
- frutas que ficam melhores com um quique;
- frutas perto de parede para ensinar ricochete;
- perigo posicionado para punir forca exagerada, nao para parecer injusto.

### Bonus por multiplas frutas

Coletar varias frutas em um unico lancamento e uma boa promessa de juice e
habilidade, mas nao entra na primeira sprint.

Guardar como evolucao natural:

- 1 fruta: coleta normal;
- 2 frutas no mesmo lancamento: bonus simples;
- 3+ frutas no mesmo lancamento: efeito visual mais forte;
- texto curto como "Combo" ou "Perfeito", se isso nao poluir a tela.

### Objetos especiais

Objetos com habilidades especificas ficam no backlog pos-MVP.

Exemplos possiveis:

- mola: muda direcao ou aumenta velocidade;
- gel: reduz velocidade;
- bumper: rebate com mais forca;
- fruta pesada: precisa de impacto mais forte;
- portal: teletransporta o slime.

Esses objetos so devem entrar depois que slime, mira, quique, coleta, perigo
e restart estiverem funcionando bem.

## Arquitetura alvo inicial

Manter objetos pequenos e com responsabilidades claras.

```text
Main
  controla fase atual, pontuacao, vitoria, derrota e restart

Level
  guarda a composicao manual da fase

Slime
  controla input, estados, velocidade, quique e parada

Fruit
  detecta coleta e emite sinal

Spike
  detecta perigo e emite sinal

Arena
  contem paredes e limites fisicos

UI
  mostra estado do jogo, mas nao decide regra
```

Regra importante: a UI mostra informacao; `Main` decide fluxo de jogo; objetos
de fase emitem sinais quando algo acontece.

## Estados iniciais do Slime

Usar uma maquina de estado simples:

```text
IDLE -> AIMING -> MOVING -> IDLE
```

Responsabilidades:

- `IDLE`: pode iniciar arrasto;
- `AIMING`: mostra mira e calcula forca;
- `MOVING`: aplica movimento, quique, colisao e desaceleracao.

Nao criar uma maquina de estados generica neste momento. Um `enum` simples e
suficiente para treinar clareza sem aumentar arquitetura.

## Sprint 1 - Movimento basico

Objetivo:

Validar se puxar, soltar e mover o slime ja tem potencial.

Entregas:

- cena de teste com arena simples;
- slime visivel;
- input de clicar/tocar no slime;
- estado `IDLE`;
- estado `AIMING`;
- estado `MOVING`;
- forca limitada por distancia maxima de arrasto;
- velocidade aplicada ao soltar;
- desaceleracao ate parar;
- retorno para `IDLE`.

Fora da sprint:

- fruta;
- espinho;
- placar;
- fases multiplas;
- efeitos visuais;
- sons.

Criterio de conclusao:

O jogador consegue lancar o slime repetidamente e entender direcao/forca sem
tutorial longo.

Teste manual:

- puxar para baixo deve lancar para cima;
- puxar pouco deve lancar fraco;
- puxar muito deve respeitar limite;
- enquanto move, nao deve aceitar novo arrasto;
- quando parar, deve aceitar novo arrasto.

Checkpoint recomendado:

Criar commit quando o lancamento basico estiver funcionando.

Status: concluida.

## Sprint 2 - Parede e ricochete

Objetivo:

Fazer o slime quicar de forma previsivel e agradavel.

Entregas:

- arena fechada com paredes;
- colisao com paredes;
- quique usando normal da colisao;
- controle de `bounce_factor`;
- controle de `friction`;
- limite de velocidade maxima;
- ajuste para o slime nao quicar para sempre.

Fora da sprint:

- frutas;
- espinhos;
- bonus;
- camera shake;
- squash/stretch.

Criterio de conclusao:

O jogador consegue usar paredes como parte da mira, e o slime eventualmente
para sem parecer travado.

Teste manual:

- lancar contra parede vertical deve inverter horizontalmente;
- lancar contra parede horizontal deve inverter verticalmente;
- lancar em diagonal deve preservar sensacao de angulo;
- quique nao deve aumentar velocidade sem motivo;
- slime nao deve atravessar paredes em lancamentos fortes.

Checkpoint recomendado:

Criar commit quando o ricochete estiver confiavel.

Status: concluida.

## Sprint 3 - Primeira fase manual com fruta

Objetivo:

Validar o prazer de mirar e coletar.

Entregas:

- `Level_01` manual;
- uma fruta posicionada manualmente;
- fruta detecta contato com slime;
- fruta emite sinal de coleta;
- `Main` recebe sinal e soma ponto;
- UI simples mostra pontuacao;
- fase reposiciona ou respawna fruta de forma simples.

Fora da sprint:

- espinhos;
- bonus de combo;
- multiplas frutas;
- geracao procedural.

Criterio de conclusao:

Coletar fruta deve parecer claro e intencional.

Teste manual:

- tocar na fruta soma 1 ponto;
- a fruta nao soma pontos repetidos no mesmo contato;
- a UI atualiza corretamente;
- o slime continua controlavel depois da coleta.

Checkpoint recomendado:

Criar commit quando a coleta estiver confiavel.

Status: concluida.

## Sprint 4 - Perigo e restart

Objetivo:

Dar risco real a partida.

Entregas:

- `Spike` manual na fase;
- colisao fatal com slime;
- sinal de perigo ou morte;
- `Main` entra em estado de game over;
- input do slime bloqueado no game over;
- botao ou tecla de restart;
- reinicio limpa pontuacao e reposiciona objetos.

Fora da sprint:

- recorde local;
- tela inicial;
- efeitos de morte;
- slow motion;
- screen shake.

Criterio de conclusao:

A partida tem comeco, risco, fim e reinicio.

Teste manual:

- encostar no espinho encerra a partida;
- nao da para lancar depois do game over;
- restart volta a fase para estado inicial;
- pontuacao reseta corretamente.

Checkpoint recomendado:

Criar commit quando o ciclo completo jogar-morrer-reiniciar estiver funcional.

Status: concluida.

## Sprint 5 - Fases manuais de mira

Objetivo:

Descobrir se o desafio de mira sustenta o jogo.

Entregas:

- `Level_01`: fruta facil em linha reta;
- `Level_02`: fruta que incentiva um quique;
- `Level_03`: fruta perto de parede;
- `Level_04`: fruta com espinho criando risco;
- troca simples entre fases apos coletar a fruta.

Fora da sprint:

- editor de fases;
- selecao de fases;
- progressao salva;
- objetos especiais.

Criterio de conclusao:

As fases devem ensinar o jogador a mirar melhor sem texto explicativo longo.

Teste manual:

- cada fase deve ter uma intencao clara;
- nenhuma fase deve depender de sorte;
- o jogador deve entender por que perdeu;
- bater na parede deve parecer escolha valida.

Checkpoint recomendado:

Criar commit quando as quatro fases forem jogaveis.

Status: parcialmente concluida. O projeto ja carrega fases manuais e troca de
fase, mas ainda nao foram criadas quatro fases com intencoes diferentes.

## Sprint 6 - Multiplas frutas e bonus simples

Objetivo:

Testar se coletar varias frutas em um lancamento aumenta a diversao.

Entregas:

- fase com duas ou tres frutas;
- contador de frutas coletadas durante o mesmo lancamento;
- bonus simples ao coletar 2+ frutas antes de parar;
- feedback visual minimo de bonus.

Fora da sprint:

- sistema complexo de combo;
- ranking;
- multiplicadores permanentes;
- efeitos visuais elaborados.

Criterio de conclusao:

O jogador deve sentir vontade de planejar um lancamento melhor, nao apenas
coletar uma fruta por vez.

Teste manual:

- coletar 1 fruta da ponto normal;
- coletar 2 frutas no mesmo lancamento da bonus;
- bonus reinicia quando o slime para;
- bonus nao dispara duas vezes pelo mesmo conjunto.

Checkpoint recomendado:

Criar commit quando o bonus simples estiver funcionando.

Status: em andamento. O suporte a multiplas frutas por fase esta funcionando;
falta o bonus por coletar varias frutas no mesmo lancamento.

## Sprint 7 - Ajuste de feel sem polimento pesado

Objetivo:

Ajustar parametros principais antes de adicionar conteudo.

Entregas:

- revisar `max_drag_distance`;
- revisar `launch_force_multiplier`;
- revisar `friction`;
- revisar `bounce_factor`;
- revisar `min_stop_speed`;
- revisar tamanho da arena;
- revisar tamanho do slime, fruta e espinho.

Fora da sprint:

- sons;
- particulas;
- arte final;
- animacoes complexas;
- menus.

Criterio de conclusao:

O jogo deve ser divertido por pelo menos alguns minutos mesmo com visual
simples.

Teste manual:

- uma partida nao deve parecer lenta demais;
- uma partida nao deve parecer caotica demais;
- mirar deve parecer justo;
- perder deve parecer culpa do jogador, nao do sistema.

Checkpoint recomendado:

Criar commit quando os parametros principais estiverem escolhidos.

## Sprint 8 - Primeiro pacote de juice

Objetivo:

Adicionar apenas o polimento que melhora leitura e satisfacao da mecanica.

Entregas:

- linha de mira mais clara;
- indicador simples de forca;
- squash/stretch basico no slime;
- particula simples ao coletar fruta;
- feedback visual simples no game over;
- som temporario para lancar, quicar, coletar e morrer.

Fora da sprint:

- musica;
- skins;
- loja;
- upgrades;
- ranking online;
- efeitos excessivos.

Criterio de conclusao:

O jogo deve parecer mais responsivo e gostoso, sem esconder problemas da
mecanica.

Teste manual:

- feedback ajuda a entender acao;
- efeitos nao atrapalham a mira;
- tela continua legivel;
- performance continua estavel no alvo mobile/web.

Checkpoint recomendado:

Criar commit quando o primeiro pacote de juice estiver integrado.

## Backlog pos-MVP

So considerar depois das sprints principais:

- objetos especiais;
- mais fases manuais;
- tela inicial;
- selecao de fases;
- recorde local;
- export HTML5;
- sons finais;
- particulas melhores;
- dificuldade score attack;
- geracao procedural ou semi-procedural;
- modo desafio diario.
