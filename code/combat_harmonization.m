%Steps for data harmonization in MatLab

%first make sure your combat scripts are in the folder where the images are

%%%%%%%%%%%%%%%%%%%%%%% Turn your nifti files into a vector 

% Path to the CSV file containing participant information - subID, batch and mod info
covariates_file = '/path/to/your/file/';

% Read the entire CSV file into a table
covariate_data = readtable(covariates_file);

% Extract participant IDs, sex, batch (scanner site), group, and age information
p_ids = covariate_data.ID;  % Column for participant IDs
sex = covariate_data.sex;    % Column for sex
batch = covariate_data.batch; % Column for batch
group = covariate_data.group; % Column for group
age = covariate_data.age;     % Column for age

% Create file names for NIfTI files
file_names = cell(length(p_ids), 1);
gm_matrix = [];

% Generate NIfTI filenames and load the data
for i = 1:length(p_ids)
    %need to change naming convention for each study
    %this is an example of how I extracted the participant ID from my file names
    gm_nii_file_name = strcat('mwp1', p_ids{i}, '_ses-1_T1w.nii');
    file_names{i} = gm_nii_file_name;
    disp(gm_nii_file_name);

    % here you are loading in each nifti, converting it to a vector, and adding it to the matrix that will get harmonized
    gm_nii = load_nii(gm_nii_file_name);  % Load the NIfTI file
    gm_data = gm_nii.img;                  % Get the GM data as a 3D matrix
    gm_vector = gm_data(:);                 % Flatten the 3D matrix into a 1D vector
    gm_matrix = [gm_matrix gm_vector];      % Append to gm_matrix
end

%%%%%%%%%%%%%%%%%%%%%%% Removing constant values

% Remove all constant rows across all participants - this is done as a requirement for the software 
const_rows = range(gm_matrix, 2) == 0;  % Logical vector for constant rows
const_values = gm_matrix(const_rows, :);  % Store constant values
gm_matrix_no_const = gm_matrix(~const_rows, :);  % Remove constant rows

% Create the covariates matrix (including age and sex)
% pay attention to which covariates you actually have/need for the covariate matrix and the harmonized data formula
covariates_matrix = table2array(covariate_data(:, {'age', 'sex'}));

%%%%%%%%%%%%%%%%%%%%%%% Harmonization

% Run neuroCombat using the batch and covariates matrix
[harmonized_data] = combat(gm_matrix_no_const, batch, covariates_matrix, 1);

%last arguement, 1= parametric, 0=non-parametric

%%%%%%%%%%%%%%%%%%%%%%% Add constant values back in that were removed earlier

% Initialize the harmonized matrix
gm_harmonized_with_const = zeros(size(gm_matrix));

% Add harmonized data for non-constant rows
gm_harmonized_with_const(~const_rows, :) = harmonized_data;

% Reinsert constant values into constant rows
if ~isempty(const_values)
    gm_harmonized_with_const(const_rows, :) = const_values;  % Direct assignment
end


%%%%%%%%%%%%%%%%%%%%%%% Converting back to a nifti file 


% Put harmonized data back in a NIfTI file
num_subjects = length(file_names);

for i = 1:num_subjects
    % Load the original NIfTI file for the current subject
    original_filename = file_names{i};  % Use the filename from the file_names array
    gm_nii = load_nii(original_filename);  % Load the NIfTI file
    data_i = gm_nii.img;                   % Get the GM data as a 3D matrix
    
    % Reshape the harmonized data for each subject back to 3D
    gm_harmonized_3d = reshape(gm_harmonized_with_const(:, i), size(data_i));
    
    % Create a new filename by adding '_harmonized' to the original filename
    [~, name, ext] = fileparts(original_filename);  % Split the filename
    new_filename = sprintf('%s_harmonized%s', name, ext);  % Append '_harmonized'
    
    % Save the harmonized 3D data as a NIfTI file with the new filename
    save_nii(make_nii(gm_harmonized_3d), new_filename);
end




