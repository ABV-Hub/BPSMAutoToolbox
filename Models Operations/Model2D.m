classdef Model2D < handle
   
   properties
        modelName = '';
        modelFolder= '';
        dim = 2;
        tables = {};
        
        tableFileNames = {'in/swit', 'in/hflt', 'in/palg', 'in/hf_m/cont', 'in/swi_m/cont', 'in/faultpropdef'}
        tableNames     = {'SWIT', 'Heat Flow Table', 'Paleo Water Table', 'Heat Flow Map', 'Paleo Water Map', 'Fault'}      
        tableTypes     = {'pmt', 'pmt', 'pmt', 'pmdGroup', 'pmdGroup', 'pmt'}
        nTables = 0;

   end
   
   methods
       
        % =========================================================          
        function obj = Model2D(modelName, PMProjectDirectory)
            obj.modelName = modelName;
            obj.modelFolder = fullfile(PMProjectDirectory,['pm', num2str(obj.dim), 'd'], modelName);
            
            % Sorting for conveniance
            [obj.tableNames,I] = sort(obj.tableNames);
            obj.tableFileNames = obj.tableFileNames(I);
            obj.tableTypes     = obj.tableTypes(I);
            
            % Loading all model files
            obj.nTables = numel(obj.tableNames);

            readStatus = false(1,obj.nTables);
            for i = 1:obj.nTables
                try
                    tableType     = obj.tableTypes{i};
                    tableFileName = obj.tableFileNames{i};
                    switch tableType
                        case 'pmt'
                          obj.tables{i} = PMTTools.readFile(obj.getInputFileName(tableFileName, 'pmt'));               
                        case 'pma'
                          obj.tables{i} = PMATools.readFile(obj.getInputFileName(tableFileName, 'pma'));               
                        case 'pmdGroup'
                          obj.tables{i} = PMDGroupTools.readFile(obj.getInputFileName(tableFileName, 'pmt'));
                    end
                    readStatus(i) = true;
                catch
                    readStatus(i) = false;
                end       
            end
            
            % Update the tables
            obj.tableFileNames = obj.tableFileNames(readStatus);
            obj.tableNames     = obj.tableNames(readStatus);
            obj.tableTypes     = obj.tableTypes(readStatus);
            obj.nTables        = numel(obj.tableNames);
                        
        end
        % =========================================================
        function inputFileName = getInputFileName(obj, title, ext)
           inputFileName = fullfile(obj.modelFolder, [title, '.', ext]); 
        end   
        % =========================================================  
        function [] = updateModel(obj)

           for i = 1:obj.nTables
                tableType     = obj.tableTypes{i};
                tableFileName = obj.tableFileNames{i};
                table         = obj.tables{i};
                switch tableType
                    case 'pmt'
                      PMTTools.writeFile(table, obj.getInputFileName(tableFileName, 'pmt'));               
                    case 'pma'
                      PMATools.writeFile(table, obj.getInputFileName(tableFileName, 'pma'));
                    case 'pmdGroup'
                      PMDGroupTools.writeFile(table, obj.getInputFileName(tableFileName, 'pmt'));          
                end
            end
            
        end
        % =========================================================          
        function data = getData(obj, title)
           table = obj.getTable(title);
           switch table.type
               case 'pmt'
                   data = PMTTools.getData(table.data);
               case 'pma'
                   data = PMATools.getData(table.data);
               case 'pmdGroup'
                   data = PMDGroupTools.getData(table.data);
           end
        end
        % =========================================================          
        function [] = updateData(obj, title, data, key)
              
           % Defaults
           if ~exist('key', 'var'); key = []; end
           
           % Main
           table = obj.getTable(title);
           switch table.type
                case 'pmt'
                    obj.tables{table.index} = PMTTools.updateData(table.data, data, key);
                case 'pma'
                    obj.tables{table.index} = PMATools.updateData(table.data, data, key);
                case 'pmdGroup'
                    obj.tables{table.index} = PMDGroupTools.updateData(table.data, data);
           end
        end
        % =========================================================          
        function tableNames = getTableNames(obj)
           tableNames = obj.tableNames;
        end
         % =========================================================                 
        function [] = printTable(obj, title)
            table = obj.getTable(title);
            switch table.type
                case 'pmt'
                  PMTTools.print(table.data);              
                case 'pma'
                  PMATools.print(table.data);
                case 'pmdGroup'
                  PMDGroupTools.print(table.data);  
            end
        end
        
        % =========================================================                 
        function tableInfo = getTable(obj, title)
             [~,i]  = ismember(title, obj.tableNames);
             tableInfo.name = obj.tableNames{i};
             tableInfo.fileName = obj.tableFileNames{i};
             tableInfo.type = obj.tableTypes{i};
             tableInfo.data = obj.tables{i};
             tableInfo.index = i;
        end
        
   end
    
end