function sys = nw_addMatlabSource(sys, fS, name, state)

    path = pwd;
    eval(['cd ''' state.functionPath ''';']);
    P = state.functionArgs;
    save srcFunc.mat P;
    eval(['cd ''' path ''';']);

    state = rmfield(state, 'functionArgs');

    sys = sys.addprocess(name, 'dev/abrg/2009/modlin/extras/matSource', fS, state);

end
