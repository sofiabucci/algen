function r = Lagrange(b,c,D,Pmin,Pmax,extraLimit)
% LAGRANGE
% Resolve o despacho economico pelo metodo de Lagrange.

%% Garantir que os vetores sao linhas

b = b(:)';
c = c(:)';

Pmin = Pmin(:)';
Pmax = Pmax(:)';

%% Validacao

if numel(b) ~= 2 || numel(c) ~= 2
    error('O problema deve ter exatamente dois geradores.');
end

if sum(Pmin) > D
    error('A carga e inferior a potencia minima total.');
end

if sum(Pmax) < D
    error('A carga e superior a potencia maxima total.');
end

%% Solucao de Lagrange

A = [2*c(1) -2*c(2);
     1       1];

B = [b(2)-b(1);
     D];

X = A\B;
P0 = X(:)';

r.P_unconstrained = P0;

%% Limite T2

r.usedFixing = false;
r.fixedGenerator = [];
r.fixedValue = [];

P = P0;

if ~isempty(extraLimit)

    gerador = extraLimit(1);
    limite = extraLimit(2);

    if gerador ~= 1 && gerador ~= 2
        error('Gerador indicado para T2 invalido.');
    end

    if P0(gerador) > limite + 1e-10

        r.usedFixing = true;
        r.fixedGenerator = gerador;
        r.fixedValue = limite;

        outro = 3 - gerador;

        P(gerador) = limite;
        P(outro) = D - limite;

    end

end

%% Verificar limites

if any(P < Pmin - 1e-8)
    error('A solucao viola a potencia minima de um gerador.');
end

if any(P > Pmax + 1e-8)
    error('A solucao viola a potencia maxima de um gerador.');
end

if ~isempty(extraLimit)

    gerador = extraLimit(1);
    limite = extraLimit(2);

    if P(gerador) > limite + 1e-8
        error('A solucao viola o limite adicional de T2.');
    end

end

%% Custo

C1 = b(1)*P(1) + c(1)*P(1)^2;
C2 = b(2)*P(2) + c(2)*P(2)^2;

C = C1 + C2;

%% Custos marginais

lambda = b + 2*c.*P;

if r.usedFixing
    outro = 3 - r.fixedGenerator;
    lambdaSystem = lambda(outro);
else
    lambdaSystem = lambda(1);
end

%% Resultados

r.P = P;
r.C = C;
r.lambda = lambda;
r.lambdaSystem = lambdaSystem;

end