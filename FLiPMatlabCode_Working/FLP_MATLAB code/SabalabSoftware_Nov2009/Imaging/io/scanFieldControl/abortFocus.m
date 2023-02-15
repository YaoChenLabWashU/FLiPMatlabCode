function abortFocus
	global state gh
	state.internal.abortActionFunctions=0;
	
	global focusInput focusOutput pcellFocusOutput
	stop([pcellFocusOutput focusOutput focusInput]);

	while ~strcmp(get(pcellFocusOutput, 'Running'), 'Off')
		pause(0.001);
	end
	
	setPcellsToDefault;
	setStatusString('Aborting Focus...');
	
	set(gh.siGUI_ImagingControls.focusButton, 'Enable', 'off');

	while ~any(strcmp(get([pcellFocusOutput focusOutput focusInput], 'Running'), 'Off'))
		pause(0.01);
	end
	
	setPcellsToDefault;

	flushFocusData;

	if get(focusInput, 'SamplesAvailable')>0
		try
			flushdata(focusInput);
		catch
			disp('abortFocus: error in input flush data.  proceeding...');
		end
	end
	
	mp285Flush;

	
	set(gh.siGUI_ImagingControls.focusButton, 'String', 'FOCUS');
	set(gh.siGUI_ImagingControls.focusButton, 'Enable', 'on');
	set(gh.fieldAdjustGUI.focusButton, 'String', 'focus');	
%	set(gh.siGUI_ImagingControls.startLoopButton, 'Visible', 'On');

	if ~state.internal.looping
		set(gh.siGUI_ImagingControls.grabOneButton, 'Visible', 'On');
		turnOnMenus;
		state.internal.status=0;
		applyChangesToOutput;
	else
		state.internal.status=4;
		applyChangesToOutput;
		turnOffMenus;

		resetCounters;
		state.internal.abortActionFunctions=0;
		setStatusString('Resuming loop...');
	
		updateGUIByGlobal('state.internal.frameCounter');
		updateGUIByGlobal('state.internal.zSliceCounter');

		state.internal.abort=0;
		state.internal.currentMode=3;

		mainLoop;
	end

	siRedrawImages;
	setStatusString('');
	timerReleasePause('Imaging');
	
