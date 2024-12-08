import pandas as pd
import argparse,sys,logging

def parse_arguments():
	parser = argparse.ArgumentParser(description="need a feature file")
	parser.add_argument("file_path", type=str, help="Path to the feature file")
	parser.add_argument("sample_info", type=str, help="Path to the sample info")
	return parser.parse_args()

def process_file(file_path, sample_info):
	
	sample_dict = {}
	with open(sample_info) as info:
		for line in info:
			line = line.strip().split()
			sample_dict[line[0]] = line[1]
			
	df = pd.read_csv(file_path,sep='\t')
	df['Sid'] = df['SampleID'].apply(lambda x: x.split('.')[0])
	df['Region'] = df['SampleID'].apply(lambda x:x.split('.',1)[-1])

	## Nindex
	df_nindex = df[['Sid','Region','Nindex']]
	df_nindex = df_nindex.pivot_table(columns='Region',values='Nindex',index='Sid').reset_index()
	df_nindex['Type'] = df_nindex['Sid'].map(sample_dict)
	df_nindex.to_csv(f'Nindex.5M.txt',sep='\t',index=False)

	## DeltaM
	df_deltam = df[['Sid','Region','DeltaM']] 
	df_deltam = df_deltam.pivot_table(columns='Region',values='DeltaM',index='Sid').reset_index()
	df_deltam['Type'] = df_deltam['Sid'].map(sample_dict)
	df_deltam.to_csv(f'DeltaM.5M.txt',sep='\t',index=False)

	## DeltaS
	df_deltas = df[['Sid','Region','DeltaS']]
	df_deltas = df_deltas.pivot_table(columns='Region',values='DeltaS',index='Sid').reset_index()
	df_deltas['Type'] = df_deltas['Sid'].map(sample_dict)
	df_deltas.to_csv(f'DeltaS.5M.txt',sep='\t',index=False)

if __name__ == '__main__':
	args = parse_arguments()
	process_file(args.file_path, args.sample_info)
