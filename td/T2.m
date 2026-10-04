function r = T2(b,c,D,popSize,maxGen,seed,limitGenerator,limitValue,t1Cost)
% T2
% Despacho economico com limite de potencia.

%% Limites

Pmin = [0.10 0.10];
Pmax = [1.00 1.00];

extraLimit = [limitGenerator limitValue];

%% Custo T1

if isempty(t1Cost)

    base = Lagrange( ...
        b,c,D,Pmin,Pmax,[]);

    t1Cost = base.C;

end

%% Lagrange

L = Lagrange( ...
    b,c,D,Pmin,Pmax,extraLimit);

%% GA

G = GA( ...
    b,c,D,popSize,maxGen,seed,Pmin,Pmax,extraLimit);

%% Resultados Lagrange

r.P_L = L.P;
r.C_L = L.C;
r.lambda_L = L.lambda;
r.lambdaSystem_L = L.lambdaSystem;

%% Resultados GA

r.P_GA = G.P;
r.C_GA = G.C;
r.lambda_GA = G.lambda;
r.lambdaSystem_GA = G.lambdaSystem;

%% Limite

r.unconstrainedP = L.P_unconstrained;
r.usedFixing = L.usedFixing;
r.fixedGenerator = L.fixedGenerator;
r.fixedValue = L.fixedValue;

%% Acrescimo de custo

r.t1Cost = t1Cost;

r.acrescimo_L = L.C - t1Cost;
r.acrescimoPercent_L = ...
    100*(L.C-t1Cost)/t1Cost;

r.acrescimo_GA = G.C - t1Cost;
r.acrescimoPercent_GA = ...
    100*(G.C-t1Cost)/t1Cost;

%% Comparacao

r.tabelaComparacao = table( ...
    [L.P(1);G.P(1)], ...
    [L.P(2);G.P(2)], ...
    [L.C;G.C], ...
    [L.lambdaSystem;G.lambdaSystem], ...
    [L.C-t1Cost;G.C-t1Cost], ...
    'RowNames', ...
    {'Lagrange','GA'}, ...
    'VariableNames', ...
    {'P1','P2','Custo', ...
     'LambdaSistema','AcrescimoCusto'});

end