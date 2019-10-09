clc;clear;close all; 
t = linspace(0,40e-3,1e4); %time vector
VDD = 1.8;
Cs = 3e-12;     % max allowed capacitance
Ip = 750e-12;   % max pixel current
%Ip = 50e-12;   % min pixel current
Rp = VDD/Ip;    % apparent resistnace
Rds1 = 0;       % assume 0 for now
tau = (Rp + Rds1)*Cs;   % time constant
Vcs = VDD*(1-exp(-t/(tau))); % voltage accross capacitor

plot(t,Vcs);
hold on
plot(t,0.95*VDD*ones(1,length(t)))