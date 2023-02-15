% do FLiP repeat

% Set num_repeat to the number of repeats you need
% Do all other configurations in the GUI as usual
num_repeat = 2; 

i_repeat = 1;
while i_repeat <= num_repeat
    fprintf('Current repeat %d\n', i_repeat)
    if strcmp(state.internal.statusString,'Complete') || strcmp(state.internal.statusString, 'Ready') || strcmp(state.internal.statusString, 'CycleChanged') || strcmp(state.internal.statusString, '')|| strcmp(state.internal.statusString, 'cycle saved')
        timerDoOne;
    else
        warning('Unable to repeat - check Main Control status\n');
        return; 
    end
    
    % timerDoOne function is non-blocking, so we wait until it completes
    % First, wait until FLiP acquisition time passes
    t_start = clock; 
    t_elapsed = etime(clock, t_start); 
    while t_elapsed < state.FLP.totalAcqTime
        pause(1); % Pause for one second
        t_elapsed = etime(clock, t_start); 
    end
    % Then, wait for processging and saving to complete
    while ~strcmp(state.internal.statusString, 'Complete') 
        pause(1); % Puase for one second
    end
    i_repeat = i_repeat + 1; 
end

fprintf('All repeats done\n');
    