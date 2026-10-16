function r = T1(b,c,D,popSize,maxGen,seed)
% T1
% Despacho económico sem restrições adicionais.
%
% Compara:
%   - Método de Lagrange
%   - Algoritmo Genético
%
% Efetua ainda o estudo estatístico
% de 10 execuções do GA.

%% Valores por defeito

if nargin == 0

    d = dados_grupo12();

    b = d.b;
    c = d.c;
    D = d.D;

    popSize = 50;
    maxGen = 100;
    seed = 1;

end

%% Limites

d = dados_grupo12();

Pmin = d.Pmin;
Pmax = d.Pmax;

%% Validação

if D < sum(Pmin)

    error('Carga inferior à potência mínima total.');

end

if D > sum(Pmax)

    error('Carga superior à potência máxima total.');

end

%% Resolução por Lagrange

L = Lagrange( ...
    b,c,D,...
    Pmin,Pmax,...
    []);

%% Resolução por GA

G = GA( ...
    b,c,D,...
    popSize,maxGen,seed,...
    Pmin,Pmax,...
    []);

%% Estrutura de resultados

r.Lagrange = L;

r.GA = G;

r.tabela10 = G.tabela10;

%% Comparação

r.erroPotencia = norm(L.P-G.P);

r.erroCusto = abs(L.C-G.C);

r.erroRelativoPercent = ...
    100*abs(L.C-G.C)/L.C;

%% Estatísticas do GA

r.melhor = G.melhor;

r.media = G.media;

r.pior = G.pior;

r.desvioPadrao = G.desvioPadrao;

%% Tabela estatística

r.tabelaEstatistica = table( ...
    G.melhor,...
    G.media,...
    G.pior,...
    G.desvioPadrao,...
    'VariableNames', ...
    {'Melhor','Media','Pior','DesvioPadrao'});

%% Tabela comparativa

r.tabelaComparacao = table( ...
    [L.P(1);G.P(1)], ...
    [L.P(2);G.P(2)], ...
    [L.C;G.C], ...
    [L.lambdaSystem;G.lambdaSystem], ...
    'RowNames', ...
    {'Lagrange','GA'}, ...
    'VariableNames', ...
    {'P1','P2','Custo','Lambda'});

%% Tabela de erros

r.tabelaErros = table( ...
    r.erroPotencia,...
    r.erroCusto,...
    r.erroRelativoPercent,...
    'VariableNames', ...
    {'ErroPotencia',...
     'ErroCusto',...
     'ErroRelativoPercent'});

%% Apresentação

fprintf('\n');
fprintf('====================================\n');
fprintf('T1 - DESPACHO ECONOMICO\n');
fprintf('====================================\n');

disp(r.tabelaComparacao);

fprintf('\n');
disp(r.tabelaErros);

fprintf('\nESTUDO ESTATISTICO (10 EXECUCOES)\n');

fprintf('Melhor custo  : %.6f\n',G.melhor);
fprintf('Media custo   : %.6f\n',G.media);
fprintf('Pior custo    : %.6f\n',G.pior);
fprintf('Desvio padrao : %.6f\n',G.desvioPadrao);

end