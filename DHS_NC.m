function issuccess=DHS_NC(inputfile,outputfile)

% Prediction DHSs sequences from inputfile.
%   DHS_NC(inputfile,outputfile) predict sequences from inputfile, and write results to outputfile
%  issucess=DHS_NC(inputfile,outputfile), predict sequences from inputfile, and write results to outputfile, if success, return 1, else return 0
%   DHS_NC(inputfile) predict sequences from inputfile, and write results to 'pred_result.txt' file.
%   Notes:
%   The inputfile is a fasta format file.
%   Examples:
% issucess=DHS_NC('test.fasta','test_out.txt')
% Shanxin Zhang
% shanxinzhang@jiangnan.edu.cn


if nargin<1
    issuccess=0;
    disp('No input files found');
    return;
elseif nargin<2
    outputfile='pred_result.txt';
end

%please modify the direction of the python and pse-in-one tool in your own
%computer
for i=1:4
 command=['C:\Python27\python.exe C:\Python27\Pse-in-One-1.0.3\Pse-in-One\kmer.py -f tab -l +1 -r 1 -k ',num2str(i),' ', inputfile, ' DHSs_reckmer_',num2str(i),'.txt DNA'];
 system(command);
end
 
 [head,~]=fastaread(inputfile);
 load ('model.mat');
 data=[];
 for i=1:4
  revckmer_data=importdata(['DHSs_reckmer_',num2str(i),'.txt']);
  data=[data,revckmer_data];
end
 
 test_label=ones(size(data,1),1);
 pred_label=libsvmpredict(test_label,data,nc_model,' -b 1 -q');  
         fid=fopen(outputfile,'w');
        for i=1:length(head)
            if pred_label(i)==1
                fprintf(fid,'%s is predicted as DHSs.\n',head{i});
            else
                fprintf(fid,'%s is predicted as Non DHSs.\n',head{i});
            end
        end
        fclose(fid);
        clear all;
        delete('DHSs_reckmer_1.txt','DHSs_reckmer_2.txt','DHSs_reckmer_3.txt','DHSs_reckmer_4.txt');
        issuccess=1;
end

