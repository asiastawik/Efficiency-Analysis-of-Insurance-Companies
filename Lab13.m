clc
clear
close all

load('insurance_companies.mat')

%% task 1 - tone aproach
% overall efficiency
% e0 = uY/vX;
% e1 = wZ/vX;
% e2 = uY/wZ;
% max uY_jo
% s.t.
% vX_jo = 1
% xZ_j -vX_j <=0, j=1..n
% uY_j -wZ_j <=0, j=1..n
% u, v, w >=0

% variables [v w u]
% coeffs [X Y Z]

[n,m]=size(data);
inputs = 2;
intermediate = 2;
outputs = 2;
X = data(:,1:inputs); % input
Z = data(:,inputs+1:inputs+intermediate); % intermediate
Y = data(:,inputs+intermediate+1:m); % output

e0 = nan(n,1);
e1 = nan(n,1);
e2 = nan(n,1);

for i =1:n
    model_Fare.obj = [zeros(1,inputs+intermediate) Y(i,:)]; %coeffs of wage Y
    model_Fare.modelsense='max';
    a1 = [X(i,:) zeros(1,intermediate+outputs)] ;
    a2 = [-X Z zeros(n,outputs)];
    a3 = [zeros(n,inputs) -Z Y ];
    model_Fare.A = sparse([a1; a2; a3]);
    model_Fare.rhs = [1; zeros(n*2, 1)];
    model_Fare.sense = ['=' repmat('<', 1, n*2)];
    params.outputflag=0;
    result = gurobi(model_Fare, params);

    e0(i,1) = result.objval;
    e1(i,1) = (Z(i,:)*result.x(inputs+1:inputs+intermediate))/(X(i,:) ...
        *result.x(1:inputs));
    e2(i,1) = (Y(i,:)*result.x(inputs+intermediate+1:m))/(Z(i,:) ...
        *result.x(inputs+1:inputs+intermediate));
end
[e1 e2 e0];
% no efficient unit overall 
% they should be efficient in both stages (in last column no value 1)


%% TASK 2

% uniqness - another constrain
% uY_jo = e0*vX_jo => uY_jo = e0 *1

e1_max = nan(n,1);
e2_max = nan(n,1);
for i =1:n
    model_Fare.obj = [zeros(1,inputs) Z(i,:) zeros(1, outputs)]; %coeffs of wage Y
    model_Fare.modelsense='max';
    a1 = [X(i,:) zeros(1,intermediate+outputs)] ;
    a2 = [-X Z zeros(n,outputs)];
    a3 = [zeros(n,inputs) -Z Y ];
    a4 = [zeros(1, inputs+intermediate) Y(i,:)];
    model_Fare.A = sparse([a1; a2; a3; a4]);
    model_Fare.rhs = [1; zeros(n*2, 1); e0(i,1)];
    model_Fare.sense = ['=' repmat('<', 1, n*2) '='];
    params.outputflag=0;
    result = gurobi(model_Fare, params);

    e0(i,1) = result.objval;
    e1_max(i,1) = (Z(i,:)*result.x(inputs+1:inputs+intermediate))/(X(i,:) ...
        *result.x(1:inputs));
    e2_max(i,1) = (Y(i,:)*result.x(inputs+intermediate+1:m))/(Z(i,:) ...
        *result.x(inputs+1:inputs+intermediate));
end

%[e1_max e2_max] 
%% result.objval == e1_max(end)
% if we want to calculate the ones before we can use:
% e2 = e0/e1
% or
% e0 = e1*e2