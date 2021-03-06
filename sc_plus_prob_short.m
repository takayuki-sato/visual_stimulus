function np_cal
% This program is for the arithmetic searching
% and the calculation task
clear all;

% set course --------------------------------
fixTable = 1;
setTrials = 1;
%---------------------------------------------


if fixTable == 1 % this section is the base
	% variable help-------------------------------
	% available: available number as goal, each sequence
	% available_calc: available number as goal for calc, each sequence
	% available_count: sum of available numbers, 1:2=each sequence, 3=the sum
	% available_count_calc: sum of available numbers for calc
	% goal_array: histogram from all possible combinations of one sequence
	% goal_table: all possible combinations
	% log_table: log from all possible combinations
	% p_ope: possible combinations without calculation execution
	
	% trial parameters----------------------------
% 	long = 2; % lap in long session % 2
% 	long_session = 4; % 1
% 	short = 4; % lap in short session %4
% 	short_session = 4; %3
% 	lap = long*long_session + short*short_session;
% 	
% 	conds = 4; % normal-search,support-search,normal-calc,support-calc
% 		
% 	% 1 is long session, 2 is short session
% 	cond_session(:,1) = cat(1,repmat(1,long*long_session*conds,1),repmat(2,short*short_session*conds,1));
% 	% the number is the session index
%     %cond_session(:,2) = cat(1,repmat(1,long*conds,1), repmat(2,long*conds,1), repmat(3,long*conds,1), repmat(4,long*conds,1) );
% 	%cond_session(:,2) = cat(1,repmat(1,long*long_session*conds,1), repmat(1,short*conds,1), repmat(2,short*conds,1), repmat(3,short*conds,1) );
% 	%cond_session(:,2) = cat(1,repmat(1,long*long_session*conds,1), repmat(1,short*conds,1), repmat(2,short*conds,1), repmat(3,short*conds,1), repmat(4,short*conds,1), repmat(5,short*conds,1), repmat(6,short*conds,1), repmat(7,short*conds,1), repmat(8,short*conds,1) );
% 	cond_session(:,2) = cat(1,repmat(1,long*long_session*conds,1), repmat(1,short*conds,1), repmat(2,short*conds,1), repmat(3,short*conds,1), repmat(4,short*conds,1) );
%     
%     %trials = conds*lap;
%     trials = length(cond_session);
    
    cond_session = ones(96,2);
    trials = length(cond_session);
    
	% difficulty setting
	candi = 4; %  the number of candidates
	level = [1:2]; % level of the number of search path [1:2]
	%level_calc % level for calc
	
	all_limit = 100; % maximum for all the log
	
	%---------------------------------------------
		
	% possible numbers----------------------------
	possible_goal{1} = [2:2:20]; %possible 1:20
	possible_goal{2} = [1:100]; %garanteed  1:20
	possible_operand = [1:9]; %  1:20
	possible_initial = [1:9]; %  1:20
	possible_operator = [2,3]; % +-*/
	length_initial = length(possible_initial);
	%----------------------------------------------
	
	
	'making all n-choose-k'
	tmp_ope = repmat(possible_operand',1,length_initial);
	for i=1:length_initial
		strcat(num2str(round(i/length_initial*100)),'%')
		p_ope{i} = nchoosek(setdiff(tmp_ope(:,i),possible_initial(i)), candi);
		p_ope{i} = cat(2,repmat(possible_initial(i),size(p_ope{i},1),1),p_ope{i});
	end

	'opening tree'
	counter = 1;
	for i=1:length_initial
		strcat(num2str(round(i/length_initial*100)),'%')
		for j=1:size(p_ope{i},1)
			[goal_table{i}{j} goal_array{i}{j} log_table{i}{j}] = open_tree(p_ope{i}(j,:),possible_goal,all_limit,possible_operator);
			
            if ~isempty(goal_table{i}{j})
                tmp = [];
                operand_index = [1:2:candi*2+1];
                % level validation
                for k=1:length(level)
                    tmp = cat(1,tmp,possible_goal{1}(find(goal_array{i}{j}(possible_goal{1})==level(k)))' );
                    tmp_calc = cat(1,tmp,find(goal_array{i}{j}(possible_goal{2})~=level(k) & goal_array{i}{j}(possible_goal{2})>0));
                end
                
                % duplicating validation
                dup = intersect(goal_table{i}{j}(1,operand_index) , tmp);
                dup_calc = intersect(goal_table{i}{j}(1,operand_index) , tmp_calc);
                if ~isempty(dup)
                    for l = 1:length(dup)
                        tmp(tmp==dup(l)) = [];	
                    end
                end	
                if ~isempty(dup_calc)
                    for l = 1:length(dup_calc)
                        tmp_calc(tmp_calc==dup_calc(l)) = [];	
                    end
                end	
                
                % same available
                same = intersect(tmp_calc,tmp);
                for l=1:length(same)
                    tmp_calc(tmp_calc==same(l))=[];
                end
                
                if ~isempty(tmp)	
                    available{i}{j} = sort(tmp);
                    available_count(counter,1:3) = [i,j,sum(goal_array{i}{j}(tmp))];
                end
                
                if ~isempty(tmp_calc)
                    available_calc{i}{j} = sort(tmp_calc);
                    available_count_calc(counter,1:3) = [i,j,sum(goal_array{i}{j}(tmp_calc))];
                end
                
                counter = counter + 1;
            end
		end
	end

	%available
	
	save fixTable_dif_emer.mat;
end

if setTrials == 1 % this section has random things
	'Now loading ,fixTable'
    %cd aburano;
	load fixTable_dif_emer.mat;
    
	% variable help--------------------------------
	% available_ij: numbers representing sequence as the task order
	% calc_plate: the base of calculation problems
	% dummy_index: index of insearting fake answer
	% plate: nice numbers to execute as the task order
	% plateall: nice numbers to execute including operators as the task order
	% prepare_plate: problems shown for calc
	% prob_index: problem index in available count
	% showPlate: problems shown for all
	% pool_index: problem index for pooled problems in available count
	% pool_ij: numbers representing sequence as the task order for pooled problems
	% pool_plateall: nice numbers to execute including operators as the task order for pooled problems
	% pool_plate: nice numbers to execute as the task order for pooled problems
	% showPool: pooled problems shown for all 
	
	% parameters------------------------------------
	prepared = [20 10]; % prepare long and short
	%-----------------------------------------------
    short=3;long=0;short_session=8;long_session=0;
	%short=0;long=3;short_session=0;long_session=16;
    conds=4;
	long_calc = long*long_session; % lap of long calc in total
	short_calc = short*short_session; % lap of short calc in total
	%-----------------------------------------------
	
	% task order, normal-search,support-search,normal-calc,support-calc
    %cond_session(:,1) = 1;
	cond_session(:,1) = 2;
    cond_session(:,2) = cat(1,repmat(1,short*conds,1), repmat(2,short*conds,1), repmat(3,short*conds,1), repmat(4,short*conds,1), repmat(5,short*conds,1), repmat(6,short*conds,1) , repmat(7,short*conds,1), repmat(8,short*conds,1));
	%cond_session(:,2) = cat(1,repmat(1,long*conds,1), repmat(2,long*conds,1), repmat(3,long*conds,1), repmat(4,long*conds,1), repmat(5,long*conds,1), repmat(6,long*conds,1) , repmat(7,long*conds,1), repmat(8,long*conds,1));
	%cond_session(:,2) = cat(1,repmat(1,long*conds,1), repmat(2,long*conds,1), repmat(3,long*conds,1), repmat(4,long*conds,1), repmat(5,long*conds,1), repmat(6,long*conds,1) , repmat(7,long*conds,1), repmat(8,long*conds,1) ,repmat(9,long*conds,1), %repmat(10,long*conds,1), repmat(11,long*conds,1), repmat(12,long*conds,1), repmat(13,long*conds,1), repmat(14,long*conds,1) , repmat(15,long*conds,1), repmat(16,long*conds,1));
	
	
    %cond_session(:,2) = [1 1 2 2 3 3 4 4 5 5 6 6 7 7 8 8]'; 
    % to change the number of laps

	task_order = [];
	while length(task_order) < trials
		%task_order = cat(2,task_order,randperm(4));
        %task_order = cat(2,task_order,randperm(2));
		task_order = cat(2,task_order,[2 4 1 3]); % short
		%task_order = cat(2,task_order,[4 1]);
		
		%task_order = cat(2,task_order,randperm(2)); % long
		%task_order(task_order==2)= 4;
	end
	task_order = task_order(1:trials);
    %task_order(:) = 4; % support_calc !!!!!!!!!!!!!!!!!!!!!!!!
    
    %-----------------------------------------------
    savefile =  'setTrials_dif_emer.mat';
    
	if exist(savefile) ~= 0
    	'ERROR: Overwriting the setTrials file should not happen'
    	%return
	end
	%-------------------------------------------------
	search_index{1} = find(task_order<=2 & (cond_session(:,1)==1)'); % long session
	search_index{2} = find(task_order<=2 & (cond_session(:,1)==2)'); % short session
	search_index{3} = sort([search_index{1} search_index{2}]);
	calc_index{1} = find(task_order>=3 & (cond_session(:,1)==1)'); % long session
	calc_index{2} = find(task_order>=3 & (cond_session(:,1)==2)'); % short session
	calc_index{3} = sort([calc_index{1} calc_index{2}]);
	%-----------------------------------------------
	dummy_rate = [0.5 0]; % rate of no-solution problem, long and short
	maxdummy = 30;
	%-----------------------------------------------
	pool = length(search_index{3})*5;
	%-----------------------------------------------
	
    available_count(find(available_count(:,1)==0 & available_count(:,2)==0 & available_count(:,3)==0),:) = [];
    available_count_calc(find(available_count_calc(:,1)==0 & available_count_calc(:,2)==0 & available_count_calc(:,3)==0),:) = [];
	% warning	
	if length(find(available_count_calc(:,3)>prepared(1))) < long_calc & length(find(available_count_calc(:,3)>prepared(2))) < short_calc+long_calc
		'ERROR:This setting does not work for calc'
	end
	if size(available_count,1) < trials
		'ERROR:This setting will cause appearance of some same problems'		
	end

	% problem index in available_count 
	tmp_prob_index = [];
	while length(tmp_prob_index) < trials
		tmp_prob_index = cat(2,tmp_prob_index,shuffle(1:size(available_count,1)));		
	end
	prob_index = tmp_prob_index(1:trials);
	pool_index = tmp_prob_index(trials+1:trials+pool);
	available_ij = available_count(prob_index,1:2);
	pool_ij = available_count(pool_index,1:2);
	
	% make plate
	operand_index = [1:2:2*candi+1];
	%for i = 1:1
	for i=1:trials
		% choose the numbers and possible results
		tmp_table = goal_table{available_ij(i,1)}{available_ij(i,2)};
		tmp_array = goal_array{available_ij(i,1)}{available_ij(i,2)};
		tmp_log = log_table{available_ij(i,1)}{available_ij(i,2)};
		
		% this is the goal
		tmp_result = shuffle(available{available_ij(i,1)}{available_ij(i,2)});
		tmp_result = tmp_result(1);
		%tmp_result
		
		% this is the correct path
		tmp_table = tmp_table(find(tmp_log(:,end)==tmp_result),:);
		%tmp_table
		
		tmp_table(:,end+1) = tmp_result;
		
		plateall{i} = tmp_table;
		plate{i} = tmp_table(:,[operand_index end]);
		
		showPlate{i} = plate{i}(shuffle(1:size(plate{i},1)),:);
		showPlate{i} = showPlate{i}(1,:);
		showPlate{i} = cat(2,showPlate{i}(1),shuffle(showPlate{i}(2:candi+1)),showPlate{i}(end));
	end

	% insert no-solution search problem
	dummy_index{1} = shuffle(search_index{1});
	dummy_index{1} = dummy_index{1}(1:round(length(dummy_index{1})*dummy_rate(1))); % long
	dummy_index{2} = shuffle(search_index{2});
	dummy_index{2} = dummy_index{2}(1:round(length(dummy_index{2})*dummy_rate(2))); % short
	dummy_index{3} = sort([dummy_index{1} dummy_index{2}]);
	
	old_showPlate = showPlate;
	
	for i=1:length(dummy_index{3})
		tmp_index = dummy_index{3}(i);
		tmp_ij = available_ij(tmp_index,:);
		dummy = find(goal_array{tmp_ij(1)}{tmp_ij(2)}==0);
		%dummy = dummy(dummy<maxdummy);
        dummy = intersect(possible_goal{1},dummy);
		if isempty(dummy)
			'ERROR:insearting dummy missed'
		else	
			dummy = shuffle(dummy);
			dummy = dummy(1);
			%dummy
			showPlate{i}(1,end) = dummy;
		end
		
	end
	
	% calculation preparation
	calc_plate = cell(1,trials);
	for i=1:trials
		if ~isempty(find(intersect(calc_index{3},i)))
			calc_ij = available_ij(i,:);
			goals = available_calc{calc_ij(1)}{calc_ij(2)};
            
            s_goals = available{calc_ij(1)}{calc_ij(2)};
            same = intersect(goals,s_goals);
            for l=1:length(same)
                goals(goals==same(l))=[];
            end
            
			for j=1:length(goals)
				calc_plate{i} = cat(1,calc_plate{i},goal_table{calc_ij(1)}{calc_ij(2)}(log_table{calc_ij(1)}{calc_ij(2)}(:,end)==goals(j),:));
			end
			prepare_plate{i} = calc_plate{i}(shuffle(1:size(calc_plate{i},1)),:);
			if size(prepare_plate{i},1) < prepared(cond_session(i,1))-1
				strcat('ERROR:calculation making failed at, ',num2str([calc_ij(1) calc_ij(1)]),', in task ',num2str(task_order(i)),', for version ',num2str(cond_session(i,1)))
			else
				prepare_plate{i} = prepare_plate{i}(1:prepared(cond_session(i,1))-1,:); % depends on long or short
				prepare_plate{i} = cat(1,prepare_plate{i},plateall{i}(1,1:end-1)); % add correct
				prepare_plate{i} = prepare_plate{i}(shuffle(1:prepared(cond_session(i,1))),:);
			end
		end
	end

	% search preparation in case of being solved
	for i=1:pool
		tmp_table = goal_table{pool_ij(i,1)}{pool_ij(i,2)};
		tmp_array = goal_array{pool_ij(i,1)}{pool_ij(i,2)};
		tmp_log = log_table{pool_ij(i,1)}{pool_ij(i,2)};
		
		tmp_result = shuffle(available{pool_ij(i,1)}{pool_ij(i,2)});
		tmp_result = tmp_result(1);
		
		tmp_table = tmp_table(find(tmp_log(:,end)==tmp_result),:);
		tmp_table(:,end+1) = tmp_result;
		
		pool_plateall{i} = tmp_table;
		pool_plate{i} = tmp_table(:,[operand_index end]);
		
		showPool{i} = pool_plate{i}(shuffle(1:size(pool_plate{i},1)),:);
		showPool{i} = showPool{i}(1,:);
		showPool{i} = cat(2,showPool{i}(1),shuffle(showPool{i}(2:candi+1)),showPool{i}(end));
	end
	
	save(savefile);
	
end



return


function [table, goal_array, log_table] = open_tree(plate,possible_goal,all_limit,possible_operator)
% sizes
candi=length(plate)-1;
total_candi = candi+1; digit=total_candi;
length_ope = length(possible_operator);
pow_ope = power(length_ope,candi);

table_h = prod(1:candi)*pow_ope;
table_w = 2*candi+1;
table = zeros(table_h,table_w);

% all operands
conbi = perms(plate(2:end));
all_conbi=[];
for i=1:size(conbi,1)
	all_conbi = cat(1,all_conbi,repmat(conbi(i,:),pow_ope,1));
end

% all operators
for i=1:candi
	tmp = [];
	for j=1:length_ope
		tmp = cat(1,tmp,repmat(possible_operator(j),power(length_ope,i-1),1));
	end
	tmp_ope_candi(1:pow_ope,i) = repmat(tmp,pow_ope/length(tmp),1);
end
ope_candi = repmat(tmp_ope_candi,table_h/pow_ope,1);

%  set all possiblities
table(:,1) = repmat(plate(1),table_h,1);
for i=1:candi
	table(:,2*i) = ope_candi(:,i);
	table(:,2*i+1) = all_conbi(:,i);	
end

% table
% 
% unit = zeros(prod(1:(digit-1)),digit);
% unit(:,1) = one_plate(1);
% unit(:,2:digit) = perms(one_plate([2:digit]));
% all_unit = repmat(unit,power(4,digit-1),1);
% 
% for i=1:digit
% 	table(:,2*i-1) = all_unit(:,i);
% 	if 2*i<table_w	
% 		table(:,2*i)=repmat(cat(1,repmat(1,prod(1:(digit-1))*power(4,i-1),1),repmat(2,prod(1:(digit-1))*power(4,i-1),1),repmat(3,prod(1:(digit-1))*power(4,i-1),1),repmat(4,prod(1:(digit-1))*power(4,i-1),1)),power(4,digit-i-1),1);
% 	end
% end

%table

log = zeros(table_h,candi);
for i=1:table_h
	switch table(i,2)
		case 1
			log(i,1) = table(i,1)+table(i,3);
		case 2
			log(i,1) = table(i,1)-table(i,3);
		case 3
			log(i,1) = table(i,1)*table(i,3);
		case 4
			log(i,1) = table(i,1)/table(i,3);
	end
	if digit>2
		for j=2:digit-1
			switch table(i,2*j)
				case 1
					log(i,j) = log(i,j-1)+table(i,2*j+1);
				case 2
					log(i,j) = log(i,j-1)-table(i,2*j+1);
				case 3
					log(i,j) = log(i,j-1)*table(i,2*j+1);
				case 4
					log(i,j) = log(i,j-1)/table(i,2*j+1);
			end
		end
	end
end
%table = cat(2,table,log(:,digit-1));

%log
index = check_log(log,possible_goal{2},all_limit);
%index
%table(index,:)
log_table = log(index,:);
%log_table
goal_array = count_goal(log_table(:,end),possible_goal{2});
%goal_array'
table = table(index,:);

% End Of Function-----------------------------------

function index = check_log(log,possible_goal,all_limit)
[hh ww] = size(log);

pass = 0;
for i=1:hh
	% min limit
	if min(log(i,:))>0
		% max limit
		if max(log(i,:)) < all_limit & ~isempty(setdiff(possible_goal,log(i,size(log,2)))) %log(i,size(log,2)) < maxlimit & log(i,size(log,2)) > max_minlimit
			% decimal invalid
			count=0;
			for j=1:ww
				if log(i,j)-round(log(i,j)) == 0
					count = count+1;
				end
			end
			if count == ww
				pass = cat(2,pass,i);
			end
		end
	end
end
index = pass(2:length(pass));

% End Of Function------------------------------

function goal_array = count_goal(result_log,possible_goal)
goal_array = zeros(length(possible_goal),1);
for i=1:length(result_log)
	tmp = result_log(i);
	%if tmp <= max(possible_goal)
    if ~isempty(intersect(possible_goal,tmp))
		goal_array(tmp,1) = goal_array(tmp,1) + 1;
	end
end

% End Of Function-------------------------------

function [part] = makePartIndex(data)
length_initial = length(data);
part_perms = 3;
% only when part_perms==3
part_index{1} = [1:round(length_initial/part_perms);];
part_index{2} = [round(length_initial/part_perms)+1:round(length_initial/part_perms)*2;];
part_index{3} = [round(length_initial/part_perms)*2:length_initial ];
part = part_index;
return

