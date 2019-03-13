winstyle = 'docked';
% winstyle = 'normal';

set(0,'DefaultFigureWindowStyle',winstyle)
set(0,'defaultaxesfontsize',18)
set(0,'defaultaxesfontname','Times New Roman')
% set(0,'defaultfigurecolor',[1 1 1])

% clear VARIABLES;
clear
global spatialFactor;
global c_eps_0 c_mu_0 c_c c_eta_0
global simulationStopTimes;
global AsymForcing
global dels
global SurfHxLeft SurfHyLeft SurfEzLeft SurfHxRight SurfHyRight SurfEzRight



dels = 0.75;
spatialFactor = 1;

c_c = 299792458;                  % speed of light
c_eps_0 = 8.8542149e-12;          % vacuum permittivity
c_mu_0 = 1.2566370614e-6;         % vacuum permeability
c_eta_0 = sqrt(c_mu_0/c_eps_0);


tSim = 200e-15
%f = 250e12;
f = 250e12;
lambda = c_c/f;

xMax{1} = 20e-6;
nx{1} = 200;
ny{1} = 0.75*nx{1};


Reg.n = 1;

mu{1} = ones(nx{1},ny{1})*c_mu_0;

epi{1} = ones(nx{1},ny{1})*c_eps_0;

%epi{1}(125:150,55:95)= c_eps_0*11.3;

%My additions to the code:

%{
i1 = 100;
j1 = 50;
for i = 1:10 
    i2 = i1 + i*5; 
    for j = 1:10
        j2 = 50 + j*5;
        epi{1}(i2:(i2+5), j2:(j2+5)) = c_eps_0*11.3;
    end
end
%}
%For scattering structure

%epi{1}(50:75, 75:100) = c_eps_0*11.3; %face
%epi{1}(125:150, 75:100) = c_eps_0*11.3; 
%epi{1}(50:150, 35:55) = c_eps_0*11.3; 

%ELEC STRUCTURE
%%{
epi{1}(5:15, 75:100) = c_eps_0*11.3; %'E'
epi{1}(5:50, 75:78) = c_eps_0*11.3; 
epi{1}(5:50, 86:89) = c_eps_0*11.3; 
epi{1}(5:50, 97:100) = c_eps_0*11.3; 

epi{1}(55:65, 75:100) = c_eps_0*11.3; %'L'
epi{1}(55:90, 75:78) = c_eps_0*11.3;

epi{1}(95:105, 75:100) = c_eps_0*11.3;%'E'
epi{1}(95:140, 75:78) = c_eps_0*11.3; 
epi{1}(95:140, 86:89) = c_eps_0*11.3; 
epi{1}(95:140, 97:100) = c_eps_0*11.3; 

epi{1}(145:155, 75:100) = c_eps_0*11.3;%'C'
epi{1}(145:190, 75:78) = c_eps_0*11.3;
epi{1}(145:190, 97:100) = c_eps_0*11.3;
%END of structure
%}

%epi{1}(125:150,55:70)= c_eps_0*11.3;
%epi{1}(125:150,60:75)= c_eps_0*11.3;
%epi{1}(125:150,80:95)= c_eps_0*11.3;
%epi{1}(125:150,100:125)= c_eps_0*11.3;
%epi{1}(65:75,55:125)= c_eps_0*11.3;
%epi{1}(65:75,55:95)= c_eps_0*11.3;

%End of modifications.

sigma{1} = zeros(nx{1},ny{1});
sigmaH{1} = zeros(nx{1},ny{1});

dx = xMax{1}/nx{1};
dt = 0.25*dx/c_c;
nSteps = round(tSim/dt*2);
yMax = ny{1}*dx;
nsteps_lamda = lambda/dx

movie = 1;
Plot.off = 0;
Plot.pl = 0;
Plot.ori = '13';
Plot.N = 100;
Plot.MaxEz = 1.1;
Plot.MaxH = Plot.MaxEz/c_eta_0;
Plot.pv = [0 0 90];
Plot.reglim = [0 xMax{1} 0 yMax];

% BC sets up the boundary conditions
% BC.s sets up the source 
bc{1}.NumS = 1;
bc{1}.s(1).xpos = nx{1}/4+1;
bc{1}.s(1).type = 'ss';
bc{1}.s(1).fct = @PlaneWaveBC;

%bc{1}.s(2).xpos = nx;
%bc{1}.s(2).type = 'ss';
%bc{1}.s(2).fct = @PlaneWaveBC;

% mag = -1/c_eta_0;
mag = 1;
phi = 0;
omega = f*2*pi;
betap = 0;
t0 = 30e-15;
st = -0.05;
s=0;
y0 = yMax/2;
sty = 1.5*lambda;
bc{1}.s(1).paras = {mag,phi,omega,betap,t0,st,s,y0,sty,'s'};
bc{1}.s(2).paras = {mag,phi,omega,betap,t0,st,s,y0,sty,'s'};
Plot.y0 = round(y0/dx);

bc{1}.xm.type = 'a'; % setting up lower bound
bc{1}.xp.type = 'e'; % setting up upper bound
bc{1}.ym.type = 'a'; % setting up left bound
bc{1}.yp.type = 'a'; % setting up right bound

pml.width = 20 * spatialFactor;
pml.m = 3.5;

Reg.n  = 1;
Reg.xoff{1} = 0;
Reg.yoff{1} = 0;

RunYeeReg