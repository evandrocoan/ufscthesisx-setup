# ufscthesisx

Esta não é uma classe LaTeX,
mas um pacote.

O modelo disponibilizado pela Biblioteca Universitária da UFSC em 2015,
utiliza a `abntex` versão `0.8.2`, considerada muito antiga,
portanto tratou-se de buscar a criação deste novo modelo que utiliza a classe `abntex2` versão `1.9.6`.


### Utilizando `git`

No diretório do seu projeto faça um clone (recursivo) dos arquivos do repositório,
em uma pasta chamada `setup` dentro do template da sua tese:
```bash
git clone --recursive https://github.com/evandrocoan/ufscthesisx-setup setup
```

Para usá-lo,
você deve utilizar a classe `abnTeX2` como classe do seu documento,
e então incluir `ufscthesisx` como um pacote LaTeX na seguinte ordem:
```latex
% Fixes several `abntex2` class problems
\input{setup/setup.tex}

% The UFSC font size is 10.5, but memoir embedded by `abntex2` only accepts 10 and 11pt.
% However, problem will be fixed the `ufscthesisx` package.
\documentclass[
10pt,          % Padrão UFSC para versão final
a5paper,       % Padrão UFSC para versão final
% 12pt,        % Pode usar tamanho 12pt para defesa
% a4paper,     % Pode usar a4 para defesa
twoside,       % Impressão nos dois lados da folha
chapter=TITLE, % Título de capítulos em caixa alta
section=TITLE, % Título de seções em caixa alta
]{abntex2}

% Load the UFSC thesis package
\usepackage{setup/ufscthesisx}

% Load extra commands for tables, lists, summaries, etc.
\input{setup/utilities.tex}

% Use the 'aftertext/references.bib' file to include your bibliography
\addbibresource{aftertext/references.bib}
```
Se você inverter a ordem de inclusão do biblatex,
as citações bibliográficas não irão funcionar.

Apesar das instruções iniciais do projeto serem para utilizar diretamente a classe `abntex2`,
existem algumas incompatibilidades com outros pacotes do LaTeX que precisam ser corrigidos.
Para isso você pode utilizar você pode incluir o arquivo `setup.tex` que faz as correções do `abntex2`.

Uma maneira  de utilizar esse **template**,
caso você seja usuário de `git`,
é fazer o clone desse repositório como um submodulo de sua tese,
e em seu arquivo principal incluir o seguinte cabeçalho para carregar os pacotes básicos mentionados acima.


### Mudanças

Para ver as mudanças, acesse o histórico do `git` no endereço:
1. https://github.com/evandrocoan/ufscthesisx-setup/commits/master

Ou clone este repositório e execute seguinte comando do cliente git:
```bash
git log
```
1. https://git-scm.com/book/en/v2/Git-Basics-Viewing-the-Commit-History


## Compilação

Se você quiser saber quais são todos os comandos de compilação disponíveis,
basta chamar utilizar o comando `make help`

Caso você tenha problemas,
erros ou algo não funcione,
execute o make file em modo debug.
Para isso,
basta chamar ele como você normalmente faz,
mas passando o parâmetro `debug=true`.
Por exemplo,
`make latex debug=true`.

Por conveniência,
você também pode chamar `make latex debug=a` qualquer outra coisa desde que não seja vazio.
Por exemplo,
`make latex debug=` Você também pode diretamente editar o arquivo `setup/makefile.mk` e
descomentar a linha `# ENABLE_DEBUG_MODE := true` para ativar o modo debug permanentemente.


## Licença

```
Copyright (c) 2012-2014 by abnTeX2 group at http://abntex2.googlecode.com/
Copyright (c) 2014-2015 Mateus Dubiela Oliveira
Copyright (c) 2015-2016 Adriano Ruseler
Copyright (c) 2017-2018 Evandro Coan, Luiz Rafael dos Santos

É concedida permissão, gratuitamente, a qualquer pessoa que obtenha uma cópia deste modelo e
software e arquivos de documentação associados (o "Software"), para ter estes arquivos com os
direitos de uso, cópia, modificação, mesclagem, publicar, distribuir, e permitir que as pessoas a
quem o Software seja fornecido tenham estes mesmos direitos, ambos sujeitos às seguintes condições:

O aviso de direitos autorais acima e este aviso de permissão devem ser incluídos em todas as cópias
ou partes substanciais do Software.

Os arquivos `chapters/intro.tex`, `chapters/chapter_1.tex` e `setup/ufscthesisx.sty` estão
licenciados sobre a licença LPPL (The Latex Project License). Portanto você deve respeitar essa
licença para esses arquivos ao invés dessa. Entretanto a condição a seguir continuará valendo sobre
esses arquivos licenciados pela licença LPPL:

OS ARQUIVOS NESTE REPOSITÓRIO SÃO FORNECIDOS "NO ESTADO EM QUE SE ENCONTRAM", SEM GARANTIA DE
QUALQUER TIPO, EXPRESSA OU IMPLÍCITA, INCLUINDO, MAS NÃO SE LIMITANDO ÀS GARANTIAS DE
COMERCIALIZAÇÃO, APTIDÃO PARA UM PROPÓSITO ESPECÍFICO E NÃO INFRACÇÃO. EM NENHUMA CIRCUNSTÂNCIA, OS
AUTORES OU TITULARES DE DIREITOS AUTORAIS SERÃO RESPONSÁVEIS POR QUALQUER RECLAMAÇÃO, DANOS OU OUTRA
RESPONSABILIDADE, SEJA EM AÇÃO DE CONTRATO, DELITO OU DE OUTRA FORMA, DECORRENTE, DESTE OU
RELACIONADO COM DOS ARQUIVOS DESTE REPOSITÓRIO OU O USO OU OUTRAS NEGOCIAÇÕES NO MODELO E SOFTWARE.
```




