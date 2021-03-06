function [distance,Weight,Operation,Conversion] = find_shortest_distance_narrowDP(Sequence,Graph,Nodes,Weight,threshold,width)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    table_Nodes = java.util.Hashtable;
tic;
length_Seq = length(Sequence);
[Distance_Matrix,next] = FloydWarshall(Graph,Nodes,Weight);
num_Nodes = length(Nodes);

for i = 1:2:num_Nodes,
    temp_Array = java.util.ArrayList;
    temp_Array.add(Nodes(i));
    temp_Array.add(Nodes(i+1));
    table_Nodes.put(i,temp_Array);
end

toc;
%obtain the path between each pair 
path = cell(num_Nodes,num_Nodes);
for i = 1:num_Nodes,
    for j = 1:num_Nodes,
        path{i,j} = find_Path(i,j,next,Distance_Matrix);
    end
end

%order the pair of vertices according to the number of vertices on path
%between the pair
tic;
order_Pair = zeros(num_Nodes^2,3);
count = 1;
for i = 1:num_Nodes,
    for j = 1:num_Nodes,
        order_Pair(count,1) = i;
        order_Pair(count,2) = j;
        if(i==j),
            order_Pair(count,3) = 1;
            count = count + 1;
            continue;
        end
        path_between = unique(path{i,j});
        if(path_between==inf)
            order_Pair(count,3) = inf;
        else
            order_Pair(count,3) = length(path_between) + 2;
        end
        count = count + 1;
    end
end

order_Pair = sortrows(order_Pair,3);
toc;

tic;
% S_k -> A
Dis_SingletoSingle = zeros(1,num_Nodes,length_Seq);
Opt_SingletoSingle = cell(1,num_Nodes,length_Seq);
for i = 1:length_Seq,
    Seq = Sequence(i);
    for j = 1:num_Nodes,
        temp_Node = Nodes(j);    
        cost1 = Weight(Seq+1,temp_Node+1);
        cost2 = Weight(Seq+1,9) + Weight(9,temp_Node+1);
        if(cost1>cost2),
            Weight(Seq+1,temp_Node+1) = cost2;
        end
        Dis_SingletoSingle(1,j,i) = Weight(Seq+1,temp_Node+1);
        Opt_SingletoSingle{1,j,i} = 10*i + temp_Node;  
    end
end
toc;

tic;
%S_1,S_2,...,S_k -> A
SeqtoSingle = inf(1,num_Nodes,length_Seq);
Opt_SeqtoSingle = cell(1,num_Nodes,length_Seq);
SeqtoSingle(1,:,1) = Dis_SingletoSingle(1,:,1);
Opt_SeqtoSingle(1,:,1) = Opt_SingletoSingle(1,:,1);
%build a table 
%each item denotes the cost of deletion S_1,S_2,...,S_k
delete_Table = inf(1,length_Seq);
norm_delete_Table = zeros(1,length_Seq);
delete_Table(1) = Weight(Sequence(1)+1,9);
norm_delete_Table(1) = delete_Table(1);
for i = 2:length_Seq,
    delete_Table(i) = delete_Table(i-1) + Weight(Sequence(i)+1,9);
    %norm_delete_Table(i) = delete_Table(i)/i;
    if(delete_Table(i)>threshold),
        break;
    end
end
%***********************%
for i = 2:2+width,
    if(i>length_Seq),
        break;
    end
     
    for j = 1:num_Nodes,
        %S_1,S_2,...S_i -> Nodes(j)
        %***********************************%
        if(SeqtoSingle(1,j,i-1)==inf && delete_Table(i-1)==inf),
            continue;
        end
        target_Node = Nodes(j);
        End_Seq = Sequence(i);
        % (S_1,S_2,...S_i-1) -> target_Node + delete(S_i)
        cost1 = SeqtoSingle(1,j,i-1) + Weight(End_Seq+1,9);
        
        % delete(S_1,S_2,...S_i-1) + change(S_i -> target_Node)
        cost2 = Weight(End_Seq+1,target_Node+1) + delete_Table(i-1);
        
        if(cost1>cost2),
            SeqtoSingle(1,j,i) = cost2;
            Opt_SeqtoSingle{1,j,i} = [-[1:(i-1)],10*i+target_Node];
        else
            SeqtoSingle(1,j,i) = cost1;
            Opt_SeqtoSingle{1,j,i} = [Opt_SeqtoSingle{1,j,i-1},-i];
        end
       if(SeqtoSingle(1,j,i) > threshold),
           SeqtoSingle(1,j,i) = inf;
           Opt_SeqtoSingle{1,j,i} = inf;
       end
    end
end
toc;

tic;
%S_k -> AB
SingletoPair = inf(num_Nodes,num_Nodes,length_Seq);
path_SingletoPair = cell(num_Nodes,num_Nodes,length_Seq);
opt_SingletoPair = cell(num_Nodes,num_Nodes,length_Seq);
%norm_SingletoPair = zeros(num_Nodes,num_Nodes,length_Seq);
for k = 1:length_Seq,
    Seq = Sequence(k);
    for m = 1:size(order_Pair,1),
        %*******************************%
        if(order_Pair(m,3)>width+1),
            break;
        end
        i = order_Pair(m,1);
        j = order_Pair(m,2);    
           %S_K -> A
           if(i==j),
               opt_SingletoPair{i,i,k} = Opt_SingletoSingle{1,i,k};
               SingletoPair(i,i,k) = Dis_SingletoSingle(1,i,k);
               continue;
           end
           if(path{i,j} == inf),
               opt_SingletoPair{i,j,k} = inf;
               path_SingletoPair{i,j,k} = inf;
               continue;
           end
           min_Cost = inf;
           start_Node = Nodes(i);
           end_Node = Nodes(j);           
           for p = 1:num_Nodes,
               %*********************************%
               if(Distance_Matrix(i,p)==inf||Distance_Matrix(p,j)==inf),
                   continue;
               end
               % S_k -> A + d(A->B) + insert(B)
               if(p==i),
                    cost = Weight(Seq+1,start_Node+1) +Distance_Matrix(i,j) + Weight(9,end_Node+1);
                    if(cost<min_Cost),
                        min_Cost = cost;
                        path_SingletoPair{i,j,k} = path{i,j};
                        opt_SingletoPair{i,j,k} = [k*10+start_Node,Nodes(path{i,j}),end_Node];
                    end
               % insert(A) + d(A->B) + S_k -> B
               elseif(p==j),
                    cost = Weight(9,start_Node+1) + Distance_Matrix(i,j) + Weight(Seq+1,end_Node+1);
                    if(cost<min_Cost),
                        min_Cost = cost;
                        path_SingletoPair{i,j,k} = path{i,j};
                        opt_SingletoPair{i,j,k} = [start_Node,Nodes(path{i,j}),k*10+end_Node];
                    end                              
               % insert(A) + + d(A->C) + (S_k -> C) + d(C->B) + insert(B)
               else                   
                   med_Node = Nodes(p);
                   cost = Weight(9,start_Node+1)+ Distance_Matrix(i,p) +...
                       Distance_Matrix(p,j) + Weight(Seq+1,med_Node+1) + Weight(9,end_Node+1);
                   if(cost<min_Cost),
                       min_Cost = cost;
                       temp_Path = [path{i,p},p,path{p,j}];
                       Nodes_between1 = Nodes(path{i,p});
                       Nodes_between2 = Nodes(path{p,j});
                       opt_SingletoPair{i,j,k} = [start_Node,Nodes_between1,Opt_SingletoSingle{1,p,k},...
                           Nodes_between2,end_Node];    
                       path_SingletoPair{i,j,k} = temp_Path;   
                   end
               end
           end
           SingletoPair(i,j,k) = min_Cost; 
           %norm_SingletoPair(i,j,k) = min_Cost/length(opt_SingletoPair{i,j,k});
           if(SingletoPair(i,j,k) > threshold),
               SingletoPair(i,j,k) = inf;
               path_SingletoPair{i,j,k} = inf;
               opt_SingletoPair{i,j,k} = inf;                 
           end; 
    end
end       
toc;

tic;
%obtain the distance of S_1,S_2..S_k -> AB
DistanceMatrix = inf(num_Nodes,num_Nodes,length_Seq);
pathMatrix = cell(num_Nodes,num_Nodes,length_Seq);
Opt_Path = cell(num_Nodes,num_Nodes,length_Seq);
DistanceMatrix(:,:,1) = SingletoPair(:,:,1); 
pathMatrix(:,:,1) = path_SingletoPair(:,:,1);
Opt_Path(:,:,1) = opt_SingletoPair(:,:,1);
for k = 2:length_Seq,
     for m = 1:size(order_Pair,1),
         %***********************%
         if(order_Pair(m,3)<k-width || order_Pair(m,3)>k+width),
             continue;
         end            
         i = order_Pair(m,1);
         j = order_Pair(m,2);
            if(i==j),            %S_1,S_2,...,S_k ->A
                DistanceMatrix(i,j,k) = SeqtoSingle(1,j,k);
                Opt_Path{i,i,k} = Opt_SeqtoSingle{1,i,k};
                continue;
            end
            if(path{i,j} == inf),
               Opt_Path{i,j,k} = inf;
               DistanceMatrix(i,j,k) = inf;
               pathMatrix{i,j,k} = inf;
               continue;
            end
            start_Node = Nodes(i);
            end_Node = Nodes(j);       
            min_Cost = inf;            
            %consider the single median node   
            % insert(A) + (A->C) + (S_1,S_2,...,S_k-> C) + (C->B) +
            % insert(B)
            for p = 1:num_Nodes,
                if(SeqtoSingle(1,p,k)==inf||Distance_Matrix(i,p)==inf || Distance_Matrix(p,j)==inf)
                    continue;
                end
                %(S_1,S_2,...S_k -> A) + d(A-B) + insert(B)
                if(p==i)
                    cost = SeqtoSingle(1,i,k) + Distance_Matrix(i,j) + Weight(9,end_Node+1);
                    if(cost<min_Cost),
                        min_Cost = cost;
                        
                        pathMatrix{i,j,k} = path{i,j};
                        Opt_Path{i,j,k} = [Opt_SeqtoSingle{1,p,k},Nodes(path{p,j}),end_Node];
                    end
                %(S_1,S_2....S_k ->B) + d(A-B) + insert(A)
                elseif(p==j),
                    cost = Weight(9,start_Node+1) + Distance_Matrix(i,j) + SeqtoSingle(1,j,k);
                    if(cost<min_Cost),
                        min_Cost = cost;
                      
                        pathMatrix{i,j,k} = path{i,j};
                        Opt_Path{i,j,k} = [start_Node,Nodes(path{i,j}),Opt_SeqtoSingle{1,p,k}];
                    end
                %insert(A) + d(A-C) + (S_1,S_2,...S_k ->C) + d(C-B) +
                %insert(B)
                else
                    cost = Weight(9,start_Node+1)+ Weight(9,end_Node+1)+...
                        SeqtoSingle(1,p,k) + Distance_Matrix(i,p) + Distance_Matrix(p,j);
                    if(cost<min_Cost)
                        min_Cost = cost;                      
                        pathMatrix{i,j,k} = [path{i,p},p,path{p,j}];
                        Opt_Path{i,j,k} = [start_Node,Nodes(path{i,p}),Opt_SeqtoSingle{1,p,k},...
                            Nodes(path{p,j}),end_Node];
                    end
                end                              
            end 
            
            DistanceMatrix(i,j,k) = min_Cost;
            
            %consider two median nodes
            % (S_1,S_2,...,S_k-1 ->AC_1) + (C_1,C_2) + (S_k -> C_2B)
            for p = 1:num_Nodes,
                if(DistanceMatrix(i,p,k-1)==inf),
                    continue;
                end
                med_Node1 = Nodes(p);
                Neighbors = Graph(p,:);
                index = find(Neighbors~=0);
                for q = 1:length(index),
                    if(index(q)==p)
                        continue;
                    end
                    if(SingletoPair(index(q),j,k)==inf),
                        continue;
                    end
                    med_Node2 = Nodes(index(q));
                    cost = DistanceMatrix(i,p,k-1) + SingletoPair(index(q),j,k);
                    if(cost<min_Cost),
                        min_Cost = cost;
                        %(S_1,S_2,...,S_k-1 ->AC_1) + (C_1,C_2) + (S_k -> C_2B)
                        if(p~=i && index(q)~=j),
                            temp_Path = [pathMatrix{i,p,k-1},p,index(q),...
                                path_SingletoPair{index(q),j,k}];
                            Opt_Path{i,j,k} = [Opt_Path{i,p,k-1},...
                                opt_SingletoPair{index(q),j,k}];
                        %(S_1,S_2,...,S_k-1 -> A) + (A,C_2) + (S_k -> C_2B)
                        elseif(p==i && index(q)~=j),
                            temp_Path = [index(q),path_SingletoPair{index(q),j,k}];
                            Opt_Path{i,j,k} = [Opt_Path{i,p,k-1},...
                                opt_SingletoPair{index(q),j,k}];
                        %(S_1,S_2,...,S_k-1 -> AC_1) + (C_1,B) + (S_k -> B)
                        elseif(index(q)==j && p~=i),
                            temp_Path = [pathMatrix{i,p,k-1},p];      
                             Opt_Path{i,j,k} = [Opt_Path{i,p,k-1},Opt_SingletoSingle{1,j,k}];
                        else
                        % (S_1,S_2,...,S_k-1 ->A) + (A,B) + (S_k ->B)  
                            temp_Path = [];
                            Opt_Path{i,j,k} = [Opt_Path{i,p,k-1},Opt_SingletoSingle{1,j,k}];
                        end                           
                       pathMatrix{i,j,k} = temp_Path;
                    end
                end
            end            
            DistanceMatrix(i,j,k) = min_Cost;
            
            %delete(S_k) + (S_1,S_2,...,S_k-1 -> AB)
            if(DistanceMatrix(i,j,k-1) + Weight(Sequence(k)+1,9)<min_Cost),
                DistanceMatrix(i,j,k) = DistanceMatrix(i,j,k-1) + Weight(Sequence(k)+1,9);
                pathMatrix{i,j,k} = [pathMatrix{i,j,k-1}];
                Opt_Path{i,j,k} = [Opt_Path{i,j,k-1},-k];
            end
            %************************%
            if(DistanceMatrix(i,j,k)>threshold),
                DistanceMatrix(i,j,k) = inf;
                Opt_Path{i,j,k} = inf;
                pathMatrix{i,j,k} = inf;
            end
        end
    end                        
toc;

%calculate shortest distance in DistanceMatrix{i,j,k}
%S_1,S_2,...,S_k -> AB
k = length_Seq;
min_Cost = inf;
Opt_whole = [];
for m = 1:size(order_Pair,1),
    if(order_Pair(m,3)<length_Seq-width || order_Pair(m,3)>length_Seq+width),
        continue;
    end
    i = order_Pair(m,1);
    j = order_Pair(m,2);
    %******************%
    if(DistanceMatrix(i,j,k) ==inf),
        continue;
    end
    
    %hashtable is used to check which nodes are already on the path
    flag_Hash = java.util.Hashtable;
            for q = 1:2:num_Nodes,
                 flag_Hash.put(q,0);
            end
            cost_insert = 0;

            %temp_Node is the index of vertices on the path
            temp_Node = unique([pathMatrix{i,j,k},i,j]);
            for p = 1:length(temp_Node),
                if(mod(temp_Node(p),2)==0),
                    key_Node = temp_Node(p) - 1;
                else
                    key_Node = temp_Node(p);
                end
                flag_Hash.put(key_Node,1);
            end
            %indices of vertices that need to be inserted
            index_insert = setdiff(1:num_Nodes,temp_Node);      

            new_index_insert = [];
            %insert all nodes in the 'insert_Node'. 
            %If the same edge in the original image is already on the path,
            %don't consider the opposite direction
            for p = 1:length(index_insert),
                if(mod(index_insert(p),2) == 0),
                    key_Nodes = index_insert(p) - 1;
                else
                    key_Nodes = index_insert(p);
                end        
                if(flag_Hash.get(key_Nodes)==0),
                    flag_Hash.put(key_Nodes,1);
                    two_optional_array = table_Nodes.get(key_Nodes);
                    first_Node = two_optional_array.get(0);
                    second_Node = two_optional_array.get(1);
                    if(Weight(9,first_Node+1)<Weight(9,second_Node+1)),
                        cost_insert = cost_insert + Weight(9,first_Node+1);
                        new_index_insert = [new_index_insert,first_Node];
                    else
                        cost_insert = cost_insert + Weight(9,second_Node+1);
                        new_index_insert = [new_index_insert,second_Node];
                    end
                end          
            end        
            if(DistanceMatrix(i,j,k)+...
                    cost_insert < min_Cost)
                min_Cost = DistanceMatrix(i,j,k)+...
                    cost_insert;
                start_Node = i;
                end_Node = j;
                Opt_whole = [Opt_Path{i,j,k},Nodes(new_index_insert)];
            end
        end

distance = min_Cost;
Operation = Opt_whole;
Conversion = {};
for i = 1:length(Operation),
    if(Operation(i)<0),
        Conversion{i,1} = strcat('delete ',num2str(-Operation(i)),'th number','cost',...
            num2str(Weight(Sequence(-Operation(i))+1,9)));
        
    elseif(Operation(i)>=10),
        Original = idivide(int32(Operation(i)),int32(10),'floor');
        target = rem(Operation(i),10);
        Conversion{i,1} = strcat('change ',num2str(Original),'th number to',num2str(target),...
            'cost',num2str(Weight(Sequence(Original)+1,target+1)));
    else
        Conversion{i,1} = strcat('insert ',num2str(Operation(i)),'cost',...
            num2str(Weight(9,Operation(i)+1)));
    end
end
toc;
disp('finish');





