
function nmd_alloy_lmp_submit(NMD)


nmd_lmp_create_x0(NMD)

nmd_lmp_create_in(NMD)

nmd_lmp_create_sh(NMD)


for ish = 1:size(list.sh,1)

qsub( strcat('qsub blah lmp',int2str(ish),'.sh');

end

while exists

end


end
