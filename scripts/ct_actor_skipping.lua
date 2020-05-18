-- Function to skip actors that have no initiative
-- Modified code from 5e Ruleset, manager_combat.lua : nextActor

function onInit()
    CombatManager.nextActor = nextActor;
end

function nextActor(bSkipBell, bNoRoundAdvance)
	if not User.isHost() then
		return;
	end

	local nodeActive = CombatManager.getActiveCT();
	local nIndexActive = 0;
	
	-- Check the skip hidden NPC option
	local bSkipHidden = OptionsManager.isOption("CTSH", "on");
	-- Check the ship for actors that haven't rolled initiative
	local bSkipNonInitiativedActors = OptionsManager.isOption("CE_SNIA", "on");		
	-- Determine the next actor
	local nodeNext = nil;
	local aEntries = CombatManager.getSortedCombatantList();
	if #aEntries > 0 then
		if nodeActive then
			for i = 1,#aEntries do
				if aEntries[i] == nodeActive then
					nIndexActive = i;
					break;
				end
			end
		end
		if bSkipHidden or bSkipNonInitiativedActors then
			local nIndexNext = 0;
			for i = nIndexActive + 1, #aEntries do
				--if DB.getValue(aEntries[i], "friendfoe", "") == "friend" then       <-- Original Code: Won't skip if actor is friendly
				if DB.getValue(aEntries[i], "friendfoe", "") == "SKIP THIS SECTION JUMP RIGHT TO THE ELSE BELOW" then
					nIndexNext = i;
					-- check if initiative is 0 value (default in db if no entry). if so set index to 1 (first actor) and exit function, as all non-iniatived actors will be piled at the bottom of the CT				
					local initiative = DB.getValue(aEntries[i], 'initresult');					
					if initiative == 0 then
						nIndexActive = 0;
						Debug.console('CT actor has no rolled initiative');						
					end		
					break;
				else
					if not CombatManager.isCTHidden(aEntries[i]) then
						nIndexNext = i;
						
						-- check if initiative is 0 value (default in db if no entry). if so set index to 1 (first actor) and exit function, as all non-iniatived actors will be piled at the bottom of the CT				
						local initiative = DB.getValue(aEntries[i], 'initresult');						
						if initiative == 0 then
							nIndexNext = 0;
							Debug.console('CT actor has no rolled initiative');						
						end		
						break;
					end
				end
			end
			if nIndexNext > nIndexActive then
				nodeNext = aEntries[nIndexNext];
				for i = nIndexActive + 1, nIndexNext - 1 do
					CombatManager.showTurnMessage(aEntries[i], false);
				end
			end
		else
			nodeNext = aEntries[nIndexActive + 1];
		end
		
		-- if nodeActive then
			-- for i = 1,#aEntries do
				-- if aEntries[i] == nodeActive then
					-- nodeNext = aEntries[i+1];
				-- end
			-- end
		-- else
			-- nodeNext = aEntries[1];
		-- end
	end

	-- If next actor available, advance effects, activate and start turn
	if nodeNext then
		-- End turn for current actor
		CombatManager.onTurnEndEvent(nodeActive);
	
		-- Process effects in between current and next actors
		if nodeActive then
			CombatManager.onInitChangeEvent(nodeActive, nodeNext);
		else
			CombatManager.onInitChangeEvent(nil, nodeNext);
		end
		
		-- Start turn for next actor
		CombatManager.requestActivation(nodeNext, bSkipBell);
		CombatManager.onTurnStartEvent(nodeNext);
	elseif not bNoRoundAdvance then
		if bSkipHidden or bSkipNonInitiativedActors then
			for i = nIndexActive + 1, #aEntries do
				CombatManager.showTurnMessage(aEntries[i], false);
			end
		end
		CombatManager.nextRound(1);
	end
end