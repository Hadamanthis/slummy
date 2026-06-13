# Sprints - Slime Elastico

Este arquivo transforma o GDD em uma sequencia pratica de desenvolvimento.
O foco inicial e validar se a mecanica principal e divertida antes de investir
em polimento, conteudo extra ou sistemas grandes.

## Progresso atual

Ultima atualizacao: prototipo jogavel com movimento, ricochete, coleta,
perigo, restart, fases manuais, suporte a multiplas frutas por fase,
pontuacao calculada por lancamento, HUD de fase com primeiro passe visual
menos textual e fluxo de reinicio/avanco mais robusto.

Concluido:

- Sprint 1: movimento basico do slime;
- Sprint 2: paredes e ricochete;
- Sprint 3: coleta de fruta com sinal;
- Sprint 4: perigo, game over e restart;
- Sprint 5: carregamento de fases manuais;
- Sprint 6, parte 1: multiplas frutas por fase e troca de fase apos coletar todas;
- Sprint 6, parte 2: contar frutas coletadas no mesmo lancamento e pontuar no
  fim do lancamento;
- Sprint 7: limite de lancamentos por fase;
- Sprint 8: robustez do fluxo de fases, com `STAGE_CLEARED`, `STAGE_FAILED`,
  HUD de resultado, reinicio de fase e eventos fisicos filtrados por estado de
  gameplay.

Em andamento:

- Sprint 10: identidade visual e feedback de fase, com primeiro passe de HUD
  sobreposta menos textual e revisao dos icones de gameplay.

Decisoes registradas:

- fases ficam em `res://scenes/levels/`;
- `Main` controla fluxo da partida e carregamento de fases;
- cada cena de fase usa o script comum `scripts/level.gd`;
- `Level.max_launches` guarda quantos lancamentos aquela fase permite;
- `Slime` fica fora das cenas de fase e e reposicionado por `SlimeStart`;
- cada fase usa um container `Fruits` para permitir multiplas frutas;
- frutas e espinhos emitem sinais; `Main` decide pontuacao, troca de fase e game over;
- `Slime` emite sinais de lancamento e parada para o `Main` conseguir medir
  quantas frutas foram coletadas em um mesmo lancamento;
- a pontuacao atual e calculada no fim do lancamento como
  `fruits_collected_this_launch ** 2`;
- a proxima hipotese de core loop e tratar cada fase como um desafio com
  quantidade limitada de lancamentos.
- estrelas ficam reservadas para avaliacao/ranking de desempenho da fase, nao
  para pontuacao durante o gameplay;
- a HUD deve reservar largura fixa para valores dinamicos como `2/2` e `3/3`,
  evitando que o painel mude de tamanho quando os numeros atualizam;
- icone de lancamento e icone de pontuacao continuam pendentes: devem ser
  definidos depois que o visual da mira/lancamento e o papel da pontuacao
  estiverem mais claros.

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

Coletar varias frutas em um unico lancamento e uma boa promessa de habilidade,
mas a regra precisa ser testada como parte do core loop, nao apenas como bonus
decorativo.

A regra atual usa pontuacao quadratica por lancamento:

- 0 frutas no lancamento: 0 ponto;
- 1 fruta no lancamento: 1 ponto;
- 2 frutas no lancamento: 4 pontos;
- 3 frutas no lancamento: 9 pontos.

Essa regra muda o incentivo: o jogador deve procurar lancamentos melhores, nao
apenas coletar uma fruta por vez. Se isso deixar o jogo mais interessante, ela
vira parte central do design. Se parecer confusa ou forte demais, voltar para
`+1 por fruta` com bonus simples continua sendo uma alternativa segura.

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

## Sprint 6 - Multiplas frutas e pontuacao por lancamento

Objetivo:

Testar se coletar varias frutas em um lancamento aumenta a diversao e deixa o
core loop mais interessante.

Entregas:

- fase com duas ou tres frutas;
- contador de frutas coletadas durante o mesmo lancamento;
- pontuacao calculada no fim do lancamento;
- troca de fase apos todas as frutas serem coletadas;
- fases ajustadas para permitir lancamentos ruins, bons e excelentes.

Fora da sprint:

- sistema complexo de combo;
- ranking;
- multiplicadores permanentes;
- efeitos visuais elaborados.

Criterio de conclusao:

O jogador deve sentir vontade de planejar um lancamento melhor, nao apenas
coletar uma fruta por vez. A regra precisa ser compreensivel mesmo usando
apenas `print` como feedback temporario.

Teste manual:

- coletar 1 fruta em um lancamento da 1 ponto ao parar;
- coletar 2 frutas no mesmo lancamento da 4 pontos ao parar;
- coletar 3 frutas no mesmo lancamento da 9 pontos ao parar;
- coletar 1 fruta, parar, depois coletar outra nao gera pontuacao de combo;
- fase so troca depois que o slime para e todas as frutas acabaram.

Checkpoint recomendado:

Criar commit quando a pontuacao por lancamento estiver testada manualmente em
pelo menos duas fases.

Status: em andamento. A base tecnica da pontuacao por lancamento existe; falta
testar se a regra melhora o core loop e ajustar o desenho das fases para ela.

## Sprint 7 - Teste de core loop

Objetivo:

Descobrir se o jogo fica interessante quando cada fase tem uma limitacao clara:
coletar todas as frutas antes de acabar a quantidade de lancamentos.

Entregas:

- definir um numero simples de lancamentos por fase;
- diminuir os lancamentos restantes quando o slime e lancado;
- vencer a fase ao coletar todas as frutas;
- falhar a fase quando os lancamentos acabam e ainda existem frutas;
- reiniciar a fase ou a partida apos falha;
- revisar `Level_01` para ser possivel passar com folga;
- revisar `Level_02` para ter pelo menos uma rota melhor usando ricochete;
- criar uma pequena tabela de teste manual com 3 perguntas:
  - "entendi o que tentar?";
  - "quis tentar de novo?";
  - "o erro pareceu minha culpa?";
- decidir se a pontuacao quadratica ainda ajuda ou se o limite de lancamentos
  ja e motivacao suficiente.

Fora da sprint:

- criar muitas fases;
- adicionar objetos especiais;
- adicionar sons;
- adicionar particulas;
- criar UI final de combo.
- criar sistema de estrelas, ranking ou recorde.

Criterio de conclusao:

Depois de 5 a 10 minutos de teste, o jogo deve gerar pelo menos uma destas
vontades: passar a fase, passar com menos lancamentos ou tentar uma rota melhor.

Teste manual:

- `Level_01`: deve ser possivel vencer sem ricochete complexo;
- `Level_01`: deve ficar claro quando um lancamento foi desperdicado;
- `Level_02`: deve incentivar pelo menos um ricochete;
- quando os lancamentos acabam com frutas restantes, o jogo deve falhar;
- quando todas as frutas acabam, o jogo deve avancar de fase;
- anotar se o limite de lancamentos criou tensao boa ou frustracao.

Checkpoint recomendado:

Criar commit quando o limite de lancamentos estiver testado em pelo menos duas
fases e a decisao sobre manter ou simplificar a pontuacao estiver tomada.

## Sprint 8 - Robustez do fluxo de fases

Objetivo:

Deixar o ciclo de fase confiavel antes de adicionar mais conteudo ou polimento.
O jogador deve conseguir falhar, reiniciar, vencer e avancar sem estados
visuais presos, sinais antigos ou dependencias frageis entre fases.

Entregas:

- corrigir reinicio de fase apos `STAGE_FAILED`;
- garantir que mensagens da HUD somem ao recarregar a fase;
- garantir que sinais de fases antigas nao disparem depois do restart;
- manter `Main` como dono do fluxo de fase;
- manter `HUD` apenas refletindo estado e mensagens;
- testar falha por espinho e falha por falta de lancamentos;
- testar avanco de fase apos `STAGE_CLEARED`;
- remover variaveis, comentarios e funcoes que ficaram sem uso.

Fora da sprint:

- ajustar feel fino;
- adicionar sons;
- adicionar particulas;
- criar tela inicial;
- criar selecao de fases;
- adicionar objetos especiais.

Criterio de conclusao:

O jogador consegue repetir uma fase falhada com um unico comando, avancar uma
fase concluida com um unico comando, e nenhuma mensagem antiga permanece na
tela depois que uma nova fase comeca.

Teste manual:

- falhar por espinho e apertar espaco deve reiniciar a mesma fase;
- falhar por lancamentos e apertar espaco deve reiniciar a mesma fase;
- concluir fase e apertar espaco deve carregar a proxima fase;
- ao reiniciar ou avancar, a mensagem central deve sumir;
- o slime deve voltar para o `SlimeStart` correto;
- a HUD deve mostrar fase, frutas, score e lancamentos corretos.

Checkpoint recomendado:

Criar commit quando o fluxo falhar/reiniciar/vencer/avancar estiver confiavel.

## Sprint 9 - Definicao das regras atuais

Objetivo:

Trabalhar mais no que ja existe antes de adicionar conteudo novo. A sprint deve
deixar claras as regras de fase, pontuacao, falha, sucesso, controle e feedback
minimo para que as proximas decisoes sejam tomadas com menos chute.

Entregas:

- decidir se a pontuacao por fase continua relevante com limite de lancamentos;
- decidir se falha por espinho e falha por falta de lancamentos usam a mesma
  mensagem ou mensagens diferentes;
- decidir o que acontece ao concluir a ultima fase temporaria;
- definir o texto minimo da HUD para resultado e proximo comando;
- revisar se frutas devem ser coletaveis em qualquer contato ou apenas em
  estados especificos de gameplay;
- revisar se perigos devem afetar apenas o slime em movimento;
- limpar nomes, comentarios temporarios e funcoes da `Main`, `Level`, `Slime`,
  `Fruit`, `Spike` e `HUD`;
- documentar as decisoes tomadas nesta sprint.

Fora da sprint:

- criar novas fases;
- adicionar objetos especiais;
- polimento visual pesado;
- ajuste fino de parametros;
- sons;
- particulas;
- sistema de estrelas;
- selecao completa de fases.

Criterio de conclusao:

O prototipo deve ter regras compreensiveis para as fases ja existentes: o
jogador entende o objetivo, entende por que falhou, sabe como tentar novamente
e a HUD nao mostra informacao que ainda nao tem papel claro.

Teste manual:

- jogar as fases atuais sem criar conteudo novo;
- anotar se a pontuacao influencia alguma decisao real;
- falhar por espinho e por lancamentos e conferir se as mensagens ajudam;
- concluir a ultima fase e conferir se o comportamento temporario e aceitavel;
- verificar se algum texto da HUD esta sobrando ou faltando;
- verificar se eventos fisicos so viram gameplay quando a regra permite.

Checkpoint recomendado:

Criar commit quando as decisoes de regra atuais estiverem registradas e o fluxo
das fases existentes estiver limpo.

## Sprint 10 - Identidade visual e feedback de fase

Objetivo:

Dar uma cara mais concreta ao jogo usando apenas o que ja existe: slime,
frutas, espinhos, fases, pontuacao e resultado. A meta nao e arte final, mas
um primeiro pacote visual que deixe o prototipo parecer mais proximo de um jogo
real e ajude a avaliar melhor o core loop.

Entregas:

- definir uma direcao visual temporaria para o slime, frutas, espinhos, arena
  e HUD;
- criar um modal simples de fim de fase para `STAGE_CLEARED` e `STAGE_FAILED`;
- definir avaliacao de desempenho por estrelas ou equivalente visual simples;
- mostrar no resultado se a fase foi vencida bem, razoavelmente ou no limite;
- melhorar a leitura visual de perigo, coleta e objetivo sem adicionar novos
  sistemas;
- manter os assets como placeholders bons, nao arte final.

Fora da sprint:

- ajuste fino de parametros;
- sons;
- particulas;
- animacoes complexas;
- selecao completa de fases.
- criar novas fases;
- adicionar objetos especiais.

Criterio de conclusao:

O jogo deve parecer visualmente mais intencional, e o jogador deve entender o
resultado da fase sem depender de console ou interpretacao abstrata da HUD.

Teste manual:

- concluir uma fase deve abrir um resultado claro;
- falhar uma fase deve abrir um resultado claro;
- o sistema de estrelas deve parecer compreensivel mesmo se ainda for simples;
- os elementos principais devem ter silhuetas e cores distintas;
- a HUD deve ajudar sem competir com a arena.

Checkpoint recomendado:

Criar commit quando o primeiro pacote visual deixar as fases atuais mais
legiveis e avaliaveis.

Status: em andamento. Primeiro passe de HUD implementado com elementos
sobrepostos, `Level` mais destacado, contador de frutas com icone, contador de
lancamentos com valor compacto e largura fixa para evitar mudanca de tamanho
ao atualizar valores. O icone de lancamento ainda e placeholder e deve ser
substituido depois que o feedback visual da mira/lancamento for melhorado.

Pendencias atuais:

- definir se a pontuacao continua visivel durante o gameplay ou se aparece
  apenas no resultado da fase;
- criar um icone proprio para pontuacao se ela permanecer como informacao
  principal;
- criar/substituir o icone de lancamento depois do visual da mira/lancamento;
- usar estrelas no modal de resultado para ranking da fase;
- criar modal de resultado com estrelas para vitoria/falha.

## Sprint 11 - Ajuste de feel sem polimento pesado

Objetivo:

Ajustar parametros principais depois que o jogo tiver uma primeira identidade
visual e feedback de resultado. A meta e calibrar o brinquedo principal com
mais informacao visual do que havia no prototipo cinza.

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

## Sprint 12 - Primeiro pacote de juice

Objetivo:

Adicionar apenas o polimento que melhora leitura e satisfacao da mecanica.

Entregas:

- linha de mira mais clara;
- indicador simples de forca;
- squash/stretch basico no slime;
- particula simples ao coletar fruta;
- feedback visual simples no resultado da fase;
- som temporario para lancar, quicar, coletar e falhar.

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

## Sprint 13 - Mais fases manuais com intencao

Objetivo:

Criar um pequeno conjunto de fases que revele se o core loop precisa de novos
elementos, mais leitura visual ou mudancas de regra.

Entregas:

- revisar `Level_01`, `Level_02` e `Level_03` com uma intencao clara;
- criar pelo menos uma quarta fase manual;
- cada fase deve testar uma pergunta diferente de design;
- documentar a intencao de cada fase em uma tabela simples;
- evitar adicionar objetos especiais antes de saber qual problema eles resolvem.

Fora da sprint:

- polimento visual pesado;
- ajuste fino de parametros;
- sons;
- particulas;
- selecao completa de fases.

Criterio de conclusao:

As fases devem expor se o jogo precisa de mais obstaculos, melhor feedback,
melhor UI ou apenas melhor desenho de arena.

Teste manual:

- cada fase deve ter uma rota esperada;
- cada fase deve ter pelo menos um erro comum observavel;
- nenhuma fase deve depender de sorte;
- o jogador deve entender por que falhou.

Checkpoint recomendado:

Criar commit quando houver um pequeno pacote de fases manuais jogaveis e com
intencao clara.

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
