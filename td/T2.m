function r = T2(b,c,D,popSize,maxGen,seed,limitGenerator,limitValue,t1Cost)
% T2
% Despacho económico com restrição de potência.
%
% Compara:
%   - Método de Lagrange
%   - Algoritmo Genético
%
% Aplica uma restrição adicional de potência a um dos
% geradores e compara os resultados com o T1.
%
% Entradas:
%   b                Coeficientes lineares.
%   c                Coeficientes quadráticos.
%   D                Carga total.
%   popSize          Tamanho da população.
%   maxGen           Número máximo de gerações.
%   seed             Semente de aleatoriedade.
%   limitGenerator   Gerador sujeito à restrição.
%   limitValue       Valor máximo permitido.
%   t1Cost           Custo obtido no T1.
%
% Saída:
%   r                Estrutura com os resultados.

%% Valores por defeito

if nargin == 0

    d = dados_grupo12();

    b = d.b;
    c = d.c;
    D = d.D;

    popSize = 50;
    maxGen = 100;
    seed = 1;

    limitGenerator = d.T2.generator;
    limitValue = d.T2.max;

    t1Cost = [];

end

%% Limites dos geradores

d = dados_grupo12();

Pmin = d.Pmin;
Pmax = d.Pmax;

extraLimit = [limitGenerator limitValue];

%% Obter custo base do T1

if isempty(t1Cost)

    base = Lagrange( ...
        b,c,D,...
        Pmin,Pmax,...
        []);

    t1Cost = base.C;

end

%% Resolução por Lagrange

L = Lagrange( ...
    b,c,D,...
    Pmin,Pmax,...
    extraLimit);

%% Resolução por Algoritmo Genético

G = GA( ...
    b,c,D,...
    popSize,...
    maxGen,...
    seed,...
    Pmin,...
    Pmax,...
    extraLimit);

%% Guardar resultados individuais

r.Lagrange = L;

r.GA = G;

%% Acréscimo de custo relativamente ao T1

r.acrescimo_L = L.C - t1Cost;

r.acrescimoPercent_L = ...
    100*(L.C - t1Cost)/t1Cost;

r.acrescimo_GA = G.C - t1Cost;

r.acrescimoPercent_GA = ...
    100*(G.C - t1Cost)/t1Cost;

%% Comparação entre métodos

r.erroPotencia = norm(L.P - G.P);

r.erroCusto = abs(L.C - G.C);

r.erroRelativoPercent = ...
    100*abs(L.C - G.C)/L.C;

%% Informação da restrição

r.limitGenerator = limitGenerator;

r.limitValue = limitValue;

r.unconstrainedP = L.P_unconstrained;

r.usedFixing = L.usedFixing;

%% Texto explicativo da restrição

if L.usedFixing

    outro = 3 - limitGenerator;

    r.explicacao = sprintf( ...
        ['O gerador %d ultrapassava o limite de %.2f MW. ' ...
         'A potência foi fixada nesse valor e a potência ' ...
         'remanescente foi atribuída ao gerador %d.'], ...
         limitGenerator,...
         limitValue,...
         outro);

else

    r.explicacao = ...
        'A restrição adicional não ficou ativa.';

end

%% Tabela comparativa principal

r.tabelaComparacao = table( ...
    [L.P(1); G.P(1)], ...
    [L.P(2); G.P(2)], ...
    [L.C; G.C], ...
    [L.lambdaSystem; G.lambdaSystem], ...
    [L.C - t1Cost; G.C - t1Cost], ...
    'RowNames', ...
    {'Lagrange','GA'}, ...
    'VariableNames', ...
    {'P1', ...
     'P2', ...
     'Custo', ...
     'LambdaSistema', ...
     'AcrescimoCusto'});

%% Tabela de erros

r.tabelaErros = table( ...
    r.erroPotencia,...
    r.erroCusto,...
    r.erroRelativoPercent,...
    'VariableNames', ...
    {'ErroPotencia', ...
     'ErroCusto', ...
     'ErroRelativoPercent'});

%% Apresentação dos resultados

fprintf('\n');
fprintf('====================================\n');
fprintf('T2 - DESPACHO COM RESTRICAO\n');
fprintf('====================================\n');

%% Solução sem restrição

fprintf('\n');
fprintf('SOLUCAO LIVRE (ANTES DA RESTRICAO)\n');

fprintf('P1 = %.6f MW\n', ...
    L.P_unconstrained(1));

fprintf('P2 = %.6f MW\n', ...
    L.P_unconstrained(2));

%% Informação da restrição

fprintf('\n');
fprintf('RESTRICAO APLICADA\n');

fprintf('Gerador limitado : G%d\n', ...
    limitGenerator);

fprintf('Limite aplicado  : %.6f MW\n', ...
    limitValue);

%% Comparação

fprintf('\n');
disp(r.tabelaComparacao);

fprintf('\n');
disp(r.tabelaErros);

%% Explicação

fprintf('\n');
fprintf('%s\n',r.explicacao);

%% Acréscimo de custo

fprintf('\n');
fprintf('ACRESCIMO DE CUSTO\n');

fprintf('Lagrange            : %.6f\n', ...
    r.acrescimo_L);

fprintf('GA                  : %.6f\n', ...
    r.acrescimo_GA);

fprintf('Lagrange (%%)        : %.4f %%\n', ...
    r.acrescimoPercent_L);

fprintf('GA (%%)              : %.4f %%\n', ...
    r.acrescimoPercent_GA);

end
