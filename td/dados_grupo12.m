function d = dados_grupo12()
% DADOS_GRUPO12
% Dados do Grupo 12.

%% Coeficientes

d.b = [0.24 0.37];
d.c = [0.43 0.24];

%% Cargas

d.PD = [0.57 0.62];
d.D = sum(d.PD);

%% Limites

d.Pmin = [0.10 0.10];
d.Pmax = [1.00 1.00];

%% Limite T2

d.T2.generator = 2;
d.T2.max = 0.45;

end