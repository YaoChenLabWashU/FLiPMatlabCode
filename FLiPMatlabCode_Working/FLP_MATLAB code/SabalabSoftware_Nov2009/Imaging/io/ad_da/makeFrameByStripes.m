function makeFrameByStripes(ai, SamplesAcquired)
	global state imageData

% makeFrame.m*****
% Data Acquisition (SamplesAcquired) Action Function
% Used with the contMode.m script to update frames on the screen after each frame.
% Takes data from data acquisition engine and formats it into a proper intensity image.
%
% This function will take the datainput from the DAQ engine and remove the data for the
% lines that are acquired.  It will then bin the matrix along the columns to produce a final image
% 
% The image will update every frame on the screen as data is recorded.
% The data is stored in the cell array imageData{X}(:,:,frames)(X = 1,2,3...) , where X is the channel Acquired the frames are indexed in the third dimension.
% 
% This action function also handles averaging over frames.
% 
% Written by: Thomas Pologruto and Bernardo Sabatini
% Cold Spring Harbor Labs
% January 31, 2001

% Write complete header string  for only the first frame
% st1=0;
% st2=0;
% 	[err, st1]=calllib('spcm32','SPC_get_actual_coltime',0, st1);
% 	[err, st2]=calllib('spcm32','SPC_get_time_from_start',0, st2);
%     [st1 st2 st1+st2]
    
    
	global grabInput
	stripeData = getdata(grabInput, state.internal.samplesPerStripe, 'double'); 
	% Gets enoogh data for one stripe from the DAQ engine for all channels present

	if state.internal.stripeCounter==0
		if state.internal.looping==1
			state.internal.secondsCounter=floor(state.internal.lastTimeDelay-etime(clock,state.internal.triggerTime));
		else
			state.internal.secondsCounter=floor(etime(clock,state.internal.triggerTime));
		end
		updateGUIByGlobal('state.internal.secondsCounter');
	end
	
	try
		if (state.internal.frameCounter==state.acq.numberOfFrames-1) && (state.internal.stripeCounter==state.internal.numberOfStripes-1)
			if state.acq.numberOfZSlices > 1
				startMoveStackFocus; 	% start movement - focal plane down one step
			end
		end
	catch
		disp(['Error in makeFromByStripes (1) : ' lasterr]);
	end
	
 	try
		siProcessImageStripe(stripeData, state.acq.averaging);
		state.internal.stripeCounter = state.internal.stripeCounter + 1;
	catch
		if state.internal.abortActionFunctions
			abortGrab
			siRedrawImages
			return
		else
			setStatusString('Error in frame by stripes');
			disp('makeFrameByStripes: Error in action function');
			disp(lasterr);
		end
	end
	
	
	if state.internal.stripeCounter==state.internal.numberOfStripes % we finished a fram
		state.internal.frameCounter=state.internal.frameCounter + 1;	% Increments the frameCounter to ensure proper image storage and display
		updateGUIByGlobal('state.internal.frameCounter');	% Updates the frame Counter on the main controls GUI.
		state.internal.stripeCounter=0;
		
		if state.internal.keepAllSlicesInMemory
			if state.acq.averaging
				framePosition=state.internal.zSliceCounter + 1;
			else
				framePosition=(state.internal.frameCounter + state.internal.zSliceCounter*state.acq.numberOfFrames);
			end
		else
			if state.acq.averaging
				framePosition=1;
			else
				framePosition = state.internal.frameCounter;
			end
		end
		
		global lastAcquiredFrame
		for channel=find(state.acq.acquiringChannel)
			imageData{channel}(:,:,framePosition)=lastAcquiredFrame{channel}(:,:);
			if state.acq.dualLaserMode==2
				imageData{channel+10}(:,:,framePosition)=lastAcquiredFrame{channel+10}(:,:);
			end
			
		end
		
		if state.internal.abortActionFunctions
			abortGrab
			siRedrawImages
			return
		end

		if state.internal.frameCounter >= state.acq.numberOfFrames 
			endAcquisition	% we finished the required frames for this slice 	
		end
	end

	
	if state.internal.abortActionFunctions
		abortGrab
		siRedrawImages
		return
	end

