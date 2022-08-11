function jbm_todo()

todo_dirpath = 'C:\Users\Josh\Desktop\todo';
todo_filepath = [todo_dirpath '\todo.mat'];

if ~exist(todo_filepath)
    todo_struct = [];
    save(todo_filepath,'todo_struct');
elseif exist(todo_filepath)
    temp = load(todo_filepath);
    todo_struct = temp.todo_struct;
end

modified_todo_struct = todo_engine(todo_struct);
todo_struct = modified_todo_struct;
save(todo_filepath,'todo_struct');               
end

function modified_todo_struct = todo_engine(todo_struct)

prompt = '+ ';
usr_input = input(prompt,'s');

switch usr_input
    
    case 'add'
        category = input(prompt,'s');
        item = input(prompt,'s');
        if isfield(todo_struct,category)
            catlength = length(todo_struct.(category));
            todo_struct.(category){catlength+1} = item;      
        else
            todo_struct.(category){1} = item;
        end
        disp(todo_struct);
        todo_struct = todo_engine(todo_struct);
        
    case 'did'
    case 'rmcat'
    case 'addcat'
    case 'display'
        if ~exist(todo_struct)
            disp('Add something first!')
            todo_struct = todo_engine(todo_struct);
        else fields = fieldnames(todo_struct);
        for i = 1:length(fields)
            field = fields{i};
            disp(['*****' field '*****']);
            for j = 1:length(todo_struct.(field))
                disp([num2str(j) '.' todo_struct.(field){j}]);
            end
        end
        todo_struct = todo_engine(todo_struct);
        end
        
    case 'backup'
    case 'reset'
        todo_struct = [];
        disp('todo_struct deleted');
        todo_struct = todo_engine(todo_struct);
    case 'exit'
      
    otherwise
        todo_struct = todo_engine(todo_struct);
end

modified_todo_struct = todo_struct;
end