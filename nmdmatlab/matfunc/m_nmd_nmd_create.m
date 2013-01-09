function m_nmd_nmd_create( NMD )

NMD.NUM_ATOMS=length(NMD.x0.pos(:,1));
if strcmp(NMD.x0.type(2).str,'GAMMA')
	NMD.NUM_ATOMS_UCELL=NMD.NUM_ATOMS;
else
	NMD.NUM_ATOMS_UCELL=length(NMD.x0.superlattice.direct(:,1));
end
NMD.NUM_MODES=3*NMD.NUM_ATOMS_UCELL;
NMD.NUM_UCELL_COPIES=NMD.NUM_ATOMS/NMD.NUM_ATOMS_UCELL;
NMD.modemaster = 1:NMD.NUM_MODES;

NMD.NUM_TSTEPS=NMD.t_fft/NMD.t_step
NMD.w_step = 2*pi/(NMD.t_fft*NMD.dt); NMD.w_max = 2*pi/(NMD.t_step*NMD.dt*2);
NMD.NUM_OMEGAS = NMD.t_fft/(2*NMD.t_step);
NMD.kptmaster = NMD.x0.kptlist;
NMD.NUM_KPTS = size(NMD.kptmaster(:,1:3),1);
NMD.kptmaster_index = 1:NMD.NUM_KPTS;
slice_length = size(NMD.kptmaster,1)/NMD.NUM_MODESLICES;

if isfield(NMD,'cofreq')

freq=load(strcat(NMD.str.main,'/freq.dat'));
[I,J]=find(freq<NMD.cofreq);


for ii=1:1:length(I)
	for jj=1:1:length(J)
	 str.orig = 'NMD_temp';
        str.change = ['NMD_' int2str(ii) '_' int2str(jj)];
        str.cmd1 = ['-e ''s/\<' str.orig '\>/' str.change '/g'' '];
        str.orig = 'runpath';
        str.change = strcat(NMD.str.main,'/',int2str(NMD.seed.superlattice) );
        str.temp = strcat('-e ''s|',str.orig,'|',str.change);
        str.cmd2 = [str.temp '|g'' '];
        str.orig = 'NMD_TEMP.m';
        str.change = ['NMD_' int2str(ii) '_' int2str(jj) '.m'];
        str.cmd3 = ['-e ''s/\<' str.orig '\>/' str.change '/g'' '];
        str.cmd4 =...
        [NMD.temp.path '/NMD.sh.temp > ./' int2str(NMD.seed.superlattice) '/NMD_' int2str(ii) '_' int2str(jj) '.sh'];
        str.cmd = ['sed ' str.cmd1 str.cmd2 str.cmd3 str.cmd4];
        system(str.cmd);
%NMD_ISEED_IKSLICE.m-------------------------------------------------------        
        str.orig = 'ISEED';
        str.change = [int2str(1)];
        str.cmd1 = ['-e ''s/\<' str.orig '\>/' str.change '/g'' '];
        str.orig = 'IMSLICE';
        str.change = [int2str(I(ii))];
        str.cmd2 = ['-e ''s/\<' str.orig '\>/' str.change '/g'' '];
        str.orig = '1:NMD.NUM_MODES'
        str.change = strcat(int2str((jj)),':',int2str((jj)))
        str.cmd3 = ['-e ''s/\<' str.orig '\>/' str.change '/g'' '];
        str.cmd4 =...
        [NMD.temp.path '/NMD.m.temp > ./' int2str(NMD.seed.superlattice) '/NMD_' int2str(ii) '_' int2str(jj) '.m'];
	
        str.cmd = ['sed ' str.cmd1 str.cmd2  str.cmd3 str.cmd4];
        system(str.cmd);
%NMD_submit.sh------------------------------------------------------------- 
    	if strcmp(NMD.env,'gilgamesh') 	
		output =...
        	['qsub -l walltime=' int2str(NMD.matlab.walltime)...
        	':00:00,nodes=' int2str(NMD.matlab.cpu)...
        	',mem=' int2str(NMD.matlab.mem)...
        	'gb NMD_' int2str(ii) '_' int2str(jj) '.sh'];
    
    		str.write = strcat(NMD.str.main,'/',int2str(NMD.seed.superlattice),'/NMD_submit.sh');
    		dlmwrite(str.write,output,'-append','delimiter','');
        elseif strcmp(NMD.env,'ntpl')
		str.tmp=strcat(NMD.str.main,'/')
		output =['qsub  ' str.tmp int2str(NMD.seed.superlattice) '/NMD_' int2str(ii) '_' int2str(jj) '.sh'];
    
    		str.write = strcat(NMD.str.main,'/',int2str(NMD.seed.superlattice),'/NMD_submit.sh');
    		dlmwrite(str.write,output,'-append','delimiter','');
        end

	end
end

else % if nocofreq

for ikslice = 1:NMD.NUM_MODESLICES
    NMD.kpt(:,1:3,ikslice) =...
        NMD.kptmaster( (ikslice-1)*slice_length+1:(ikslice)*slice_length,1:3);
    
    NMD.kpt_index(:,ikslice) =...
        NMD.kptmaster_index( (ikslice-1)*slice_length+1:(ikslice)*slice_length);
end

for iseed=1:1

    for imode = 1:NMD.NUM_MODESLICES
%NMD_ISEED_IKSLICE.sh------------------------------------------------------        
        str.orig = 'NMD_temp';
        str.change = ['NMD_' int2str(iseed) '_' int2str(imode)];
        str.cmd1 = ['-e ''s/\<' str.orig '\>/' str.change '/g'' '];
        str.orig = 'runpath';
        str.change = strcat(NMD.str.main,'/',int2str(NMD.seed.superlattice) );
        str.temp = strcat('-e ''s|',str.orig,'|',str.change);
        str.cmd2 = [str.temp '|g'' '];
        str.orig = 'NMD_TEMP.m';
        str.change = ['NMD_' int2str(iseed) '_' int2str(imode) '.m'];
        str.cmd3 = ['-e ''s/\<' str.orig '\>/' str.change '/g'' '];
        str.cmd4 =...
        [NMD.temp.path '/NMD.sh.temp > ./' int2str(NMD.seed.superlattice) '/NMD_' int2str(iseed) '_' int2str(imode) '.sh'];
    
    
        str.cmd = ['sed ' str.cmd1 str.cmd2 str.cmd3 str.cmd4];
        system(str.cmd);
%NMD_ISEED_IKSLICE.m-------------------------------------------------------        
        str.orig = 'ISEED';
        str.change = [int2str(iseed)];
        str.cmd1 = ['-e ''s/\<' str.orig '\>/' str.change '/g'' '];
        str.orig = 'IMSLICE';
        str.change = [int2str(imode)];
        str.cmd2 = ['-e ''s/\<' str.orig '\>/' str.change '/g'' '];
        str.cmd3 =...
            [NMD.temp.path '/NMD.m.temp > ./' int2str(NMD.seed.superlattice) '/NMD_' int2str(iseed) '_' int2str(imode) '.m'];
	
        str.cmd = ['sed ' str.cmd1 str.cmd2 str.cmd3];
        system(str.cmd);
%NMD_submit.sh------------------------------------------------------------- 
    	if strcmp(NMD.env,'gilgamesh') 	
		output =...
        	['qsub -l walltime=' int2str(NMD.matlab.walltime)...
        	':00:00,nodes=' int2str(NMD.matlab.cpu)...
        	',mem=' int2str(NMD.matlab.mem)...
        	'gb NMD_' int2str(iseed) '_' int2str(imode) '.sh'];
    
    		str.write = strcat(NMD.str.main,'/',int2str(NMD.seed.superlattice),'/NMD_submit.sh');
    		dlmwrite(str.write,output,'-append','delimiter','');
        elseif strcmp(NMD.env,'ntpl')
            str.tmp=strcat(NMD.str.main,'/')
            output =['qsub  ' str.tmp int2str(NMD.seed.superlattice) '/NMD_' int2str(iseed) '_' int2str(imode) '.sh'];
    
    		str.write = strcat(NMD.str.main,'/',int2str(NMD.seed.superlattice),'/NMD_submit.sh');
    		dlmwrite(str.write,output,'-append','delimiter','');
        end	
    end
end


%NMD_grep.m-------------------------------------------------------        
    str.cmd3 = [NMD.temp.path '/NMD.m.temp > ./' int2str(NMD.seed.superlattice) '/NMD_' int2str(iseed) '_' int2str(imode) '.m'];
    str.cmd = ['sed ' str.cmd1 str.cmd2 str.cmd3];
    system(str.cmd);

end %cofreq check

%system(['cp ',NMD.temp.path,'/NMD_grep.m.temp ./',int2str(NMD.seed.superlattice),'/NMD_grep.m']);
l=1;
for grepi=1:length(NMD.seed.initial)
    str.orig = 'ICOUNT';
    str.change = [int2str(grepi)];
    str.cmd1 = ['-e ''s/\<' str.orig '\>/' str.change '/g'' ']
    str.cmd3 = [NMD.temp.path '/NMD_grep.m.temp > ./' int2str(NMD.seed.superlattice) '/grep_' int2str(l) '.m'];
    str.cmd = ['sed ' str.cmd1 str.cmd2 str.cmd3];
    system(str.cmd);
    str.orig = 'GREP_TEMP.m';
    str.change = ['grep_' int2str(l) '.m'];
    str.cmd2 = ['-e ''s/\<' str.orig '\>/' str.change '/g'' '];
    str.orig = 'runpath';
    str.change = strcat(NMD.str.main,'/',int2str(NMD.seed.superlattice) );
    str.temp = strcat('-e ''s|',str.orig,'|',str.change);
    str.cmd3 = [str.temp '|g'' '];
    str.cmd4 =...
        [NMD.temp.path '/grep.sh.temp > ./' int2str(NMD.seed.superlattice) '/grep_' int2str(l) '.sh'];
    str.cmd = ['sed ' str.cmd2 str.cmd3 str.cmd4];
    system(str.cmd);
    output =...
        	['qsub -l walltime=' int2str(NMD.matlab.walltime)...
        	':00:00,nodes=' int2str(NMD.matlab.cpu)...
        	',mem=' int2str(NMD.matlab.mem)...
        	'gb grep_' int2str(grepi) '.sh'];
    
    		str.write = strcat(NMD.str.main,'/',int2str(NMD.seed.superlattice),'/GREP_submit.sh');
    		dlmwrite(str.write,output,'-append','delimiter','');
    l=l+1;
end



%SAVE NMD structure--------------------------------------------------------  

save(strcat(NMD.str.main,'/',int2str(NMD.seed.superlattice),'/NMD.mat'), '-struct', 'NMD');

end
