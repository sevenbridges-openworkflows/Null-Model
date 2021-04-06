class: CommandLineTool
cwlVersion: v1.1
$namespaces:
  sbg: https://sevenbridges.com
id: boris_majic/genesis-toolkit-demo/null-model-r/38
baseCommand: []
inputs:
- sbg:category: Configs
  id: outcome
  type: string
  label: Outcome
  doc: Name of column in Phenotype File containing outcome variable.
- sbg:category: Categories
  id: phenotype_file
  type: File
  label: Phenotype file
  doc: RData file with AnnotatedDataFrame of phenotypes.
  sbg:fileTypes: RDATA
- sbg:altPrefix: GDS file.
  sbg:category: Configs
  id: gds_files
  type: File[]?
  label: GDS Files
  doc: List of gds files. Required if conditional_variant_file is specified.
  sbg:fileTypes: GDS
- sbg:category: Configs
  id: pca_file
  type: File?
  label: PCA File
  doc: RData file with PCA results created by PC-AiR.
  sbg:fileTypes: RDATA
- sbg:category: Categories
  id: relatedness_matrix_file
  type: File?
  label: Relatedness matrix file
  doc: RData or GDS file with a kinship matrix or GRM.
  sbg:fileTypes: GDS, RDATA, RData
- sbg:category: Configs
  sbg:toolDefaultValue: gaussian
  id: family
  type:
    type: enum
    symbols:
    - gaussian
    - poisson
    - binomial
    name: family
  label: Family
  doc: 'Depending on the output type (quantitative or qualitative) one of possible
    values should be chosen: Gaussian, Binomial, Poisson.'
- sbg:category: Configs
  id: conditional_variant_file
  type: File?
  label: Conditional Variant File
  doc: RData file with data frame of of conditional variants. Columns should include
    chromosome and variant.id. The alternate allele dosage of these variants will
    be included as covariates in the analysis.
  sbg:fileTypes: RDATA
- id: covars
  type: string[]?
  label: Covariates
  doc: Names of columns phenotype_file containing covariates.
- sbg:category: Configs
  id: group_var
  type: string?
  label: Group variate
  doc: Name of covariate to provide groupings for heterogeneous residual error variances
    in the mixed model.
- sbg:toolDefaultValue: 'TRUE'
  sbg:category: Configs
  id: inverse_normal
  type:
  - 'null'
  - type: enum
    symbols:
    - 'TRUE'
    - 'FALSE'
    name: inverse_normal
  label: Inverse normal
  doc: TRUE if an inverse-normal transform should be applied to the outcome variable.
    If Group variate is provided, the transform is done on each group separately.
- sbg:toolDefaultValue: '3'
  sbg:category: Configs
  id: n_pcs
  type: int?
  label: Number of PCs to include as covariates
  doc: Number of PCs to include as covariates.
- sbg:toolDefaultValue: marginal
  sbg:category: Configs
  id: rescale_variance
  type:
  - 'null'
  - type: enum
    symbols:
    - marginal
    - varcomp
    - none
    name: rescale_variance
  label: Rescale variance
  doc: Applies only if Inverse normal is TRUE and Group variate is provided. Controls
    whether to rescale the variance for each group after inverse-normal transform,
    restoring it to the original variance before the transform. Options are marginal,
    varcomp, or none.
- sbg:toolDefaultValue: 'TRUE'
  sbg:category: Configs
  id: resid_covars
  type:
  - 'null'
  - type: enum
    symbols:
    - 'TRUE'
    - 'FALSE'
    name: resid_covars
  label: Residual covariates
  doc: Applies only if Inverse normal is TRUE. Logical for whether covariates should
    be included in the second null model using the residuals as the outcome variable.
- sbg:category: Configs
  id: sample_include_file
  type: File?
  label: Sample include file
  doc: RData file with vector of sample.id to include.
  sbg:fileTypes: RDATA
- sbg:toolDefaultValue: '1'
  sbg:category: Input Options
  id: cpu
  type: int?
  label: CPU
  doc: 'Number of CPUs for each tool job. Default value: 1.'
- sbg:category: Configs
  sbg:toolDefaultValue: null_model
  id: output_prefix
  type: string?
  label: Output prefix
  doc: Base for all output file names. By default it is null_model.
- sbg:category: General
  sbg:toolDefaultValue: 'FALSE'
  id: norm_bygroup
  type:
  - 'null'
  - type: enum
    symbols:
    - 'TRUE'
    - 'FALSE'
    name: norm_bygroup
  label: Norm by group
  doc: If TRUE and group_var is provided, the inverse normal transform is done on
    each group separately.
outputs:
- id: configs
  doc: Config files.
  label: Config files
  type: File[]?
  outputBinding:
    glob: '*.config*'
- id: null_model_phenotypes
  doc: Phenotypes file
  label: Null model Phenotypes file
  type: File?
  outputBinding:
    glob: |-
      ${
          if(inputs.null_model_file)
          {
              return inputs.phenotype_file.basename
          }
          else
          {
              return "*phenotypes.RData"
          }
      }
    outputEval: $(inheritMetadata(self, inputs.phenotype_file))
  sbg:fileTypes: RData
- id: null_model_files
  doc: Null model file.
  label: Null model file
  type: File[]?
  outputBinding:
    glob: |-
      ${
          if(inputs.null_model_file)
          {
              return inputs.null_model_file.basename
          }
          else
          {
              if(inputs.output_prefix)
              {
                  return inputs.output_prefix + '_null_model*RData'
              }
              return "*null_model*RData"
          }
      }
  sbg:fileTypes: RData
- id: null_model_params
  doc: Parameter file
  label: Parameter file
  type: File?
  outputBinding:
    glob: '*.params'
  sbg:fileTypes: params
- id: null_model_output
  type: File[]?
  outputBinding:
    glob: |-
      ${
          if(inputs.null_model_file)
          {
              return inputs.null_model_file.basename
          }
          else
          {
              if(inputs.output_prefix)
              {
                  return inputs.output_prefix + '_null_model*RData'
              }
              return "*null_model*RData"
          }
      }
    outputEval: |-
      ${
          var result = []
          var len = self.length
          var i;

          for(i=0; i<len; i++){
              if(!self[i].path.split('/')[self[0].path.split('/').length-1].includes('reportonly')){
                  result.push(self[i])
              }
          }
          return result
      }
label: null_model.R
arguments:
- prefix: ''
  shellQuote: false
  position: 1
  valueFrom: |-
    ${
            return "Rscript /usr/local/analysis_pipeline/R/null_model.R null_model.config"
    }
- prefix: ''
  shellQuote: false
  position: 0
  valueFrom: |-
    ${
        if (inputs.cpu)
            return 'export NSLOTS=' + inputs.cpu + ' &&'
        else
            return ''
    }
- prefix: ''
  shellQuote: false
  position: 100
  valueFrom: |-
    ${
        return ' >> job.out.log'
    }
requirements:
- class: ShellCommandRequirement
- class: ResourceRequirement
  coresMin: |-
    ${
        if(inputs.cpu){
            return inputs.cpu
        }
        else{
            return 1
        }
    }
- class: DockerRequirement
  dockerPull: uwgac/topmed-master:2.8.1
- class: InitialWorkDirRequirement
  listing:
  - entryname: null_model.config
    entry: |-
      ${  

          var arg = [];
          if(inputs.output_prefix){
              var filename = inputs.output_prefix + "_null_model";
              arg.push('out_prefix \"' + filename + '\"');
              var phenotype_filename = inputs.output_prefix + "_phenotypes.RData";
              arg.push('out_phenotype_file \"' + phenotype_filename + '\"');
          }
          else{
              arg.push('out_prefix "null_model"');
              arg.push('out_phenotype_file "phenotypes.RData"');
          }
          arg.push('outcome ' + inputs.outcome);
          arg.push('phenotype_file "' + inputs.phenotype_file.basename + '"');
          if(inputs.gds_files){
              
             function isNumeric(s) {
              return !isNaN(s - parseFloat(s));
             }    
              
             var gds = inputs.gds_files[0].path.split('/').pop();    
             var right = gds.split('chr')[1];
             var chr = [];
             
             if(isNumeric(parseInt(right.charAt(1)))) chr.push(right.substr(0,2))
             else chr.push(right.substr(0,1))
             
              arg.push('gds_file "' + inputs.gds_files[0].basename.split("chr")[0] + "chr "+gds.split("chr"+chr)[1] +'"')
              
              
          }
          if(inputs.pca_file){
              arg.push('pca_file "' + inputs.pca_file.basename + '"')
          }
          if(inputs.relatedness_matrix_file){
              arg.push('relatedness_matrix_file "' + inputs.relatedness_matrix_file.basename + '"')
          }
          if(inputs.family){
              arg.push('family ' + inputs.family)
          }
          if(inputs.conditional_variant_file){
              arg.push('conditional_variant_file "' + inputs.conditional_variant_file.basename + '"')
          }
          if(inputs.covars){
              var temp = [];
              for(var i=0; i<inputs.covars.length; i++){
                  temp.push(inputs.covars[i])
              }
              arg.push('covars "' + temp.join(' ') + '"')
          }
          if(inputs.group_var){
              arg.push('group_var "' + inputs.group_var + '"')
          }
          if(inputs.inverse_normal){
              arg.push('inverse_normal ' + inputs.inverse_normal)
          }
          if(inputs.n_pcs){
              if(inputs.n_pcs > 0)
                  arg.push('n_pcs ' + inputs.n_pcs)
          }
          if(inputs.rescale_variance){
              arg.push('rescale_variance "' + inputs.rescale_variance + '"')
          }
          if(inputs.resid_covars){
              arg.push('resid_covars ' + inputs.resid_covars)
          }
          if(inputs.sample_include_file){
              arg.push('sample_include_file "' + inputs.sample_include_file.basename + '"')
          }
          if(inputs.norm_bygroup){
              arg.push('norm_bygroup ' + inputs.norm_bygroup)
          }
          return arg.join('\n')
      }
    writable: false
  - entry: |-
      ${
          return inputs.phenotype_file
      }
    writable: true
  - entry: |-
      ${
          return inputs.gds_files
      }
    writable: true
  - entry: |-
      ${
          return inputs.pca_file
      }
    writable: true
  - entry: |-
      ${
          return inputs.relatedness_matrix_file
      }
    writable: true
  - entry: |-
      ${
          return inputs.conditional_variant_file
      }
    writable: true
  - entry: |-
      ${
          return inputs.sample_include_file
      }
    writable: true
- class: InlineJavascriptRequirement
  expressionLib:
  - |2-

    var setMetadata = function(file, metadata) {
        if (!('metadata' in file))
            file['metadata'] = metadata;
        else {
            for (var key in metadata) {
                file['metadata'][key] = metadata[key];
            }
        }
        return file
    };

    var inheritMetadata = function(o1, o2) {
        var commonMetadata = {};
        if (!Array.isArray(o2)) {
            o2 = [o2]
        }
        for (var i = 0; i < o2.length; i++) {
            var example = o2[i]['metadata'];
            for (var key in example) {
                if (i == 0)
                    commonMetadata[key] = example[key];
                else {
                    if (!(commonMetadata[key] == example[key])) {
                        delete commonMetadata[key]
                    }
                }
            }
        }
        if (!Array.isArray(o1)) {
            o1 = setMetadata(o1, commonMetadata)
        } else {
            for (var i = 0; i < o1.length; i++) {
                o1[i] = setMetadata(o1[i], commonMetadata)
            }
        }
        return o1;
    };
hints:
- class: sbg:AWSInstanceType
  value: r4.8xlarge;ebs-gp2;500
- class: sbg:SaveLogs
  value: job.out.log
sbg:projectName: GENESIS toolkit - DEMO
sbg:image_url:
sbg:revisionsInfo:
- sbg:revision: 0
  sbg:modifiedBy: boris_majic
  sbg:modifiedOn: 1570633733
  sbg:revisionNotes: Copy of boris_majic/genesis-toolkit-dev/null-model-r/0
- sbg:revision: 1
  sbg:modifiedBy: boris_majic
  sbg:modifiedOn: 1571830034
  sbg:revisionNotes: Copy of boris_majic/genesis-toolkit-dev/null-model-r/1
- sbg:revision: 2
  sbg:modifiedBy: boris_majic
  sbg:modifiedOn: 1571831344
  sbg:revisionNotes: Copy of boris_majic/genesis-toolkit-dev/null-model-r/2
- sbg:revision: 3
  sbg:modifiedBy: boris_majic
  sbg:modifiedOn: 1572272533
  sbg:revisionNotes: Copy of boris_majic/genesis-toolkit-dev/null-model-r/3
- sbg:revision: 4
  sbg:modifiedBy: boris_majic
  sbg:modifiedOn: 1573061752
  sbg:revisionNotes: Copy of boris_majic/genesis-toolkit-dev/null-model-r/6
- sbg:revision: 5
  sbg:modifiedBy: boris_majic
  sbg:modifiedOn: 1573062816
  sbg:revisionNotes: Copy of boris_majic/genesis-toolkit-dev/null-model-r/7
- sbg:revision: 6
  sbg:modifiedBy: boris_majic
  sbg:modifiedOn: 1574250829
  sbg:revisionNotes: Copy of boris_majic/genesis-toolkit-dev/null-model-r/8
- sbg:revision: 7
  sbg:modifiedBy: boris_majic
  sbg:modifiedOn: 1574268733
  sbg:revisionNotes: Copy of boris_majic/genesis-toolkit-dev/null-model-r/9
- sbg:revision: 8
  sbg:modifiedBy: boris_majic
  sbg:modifiedOn: 1575643018
  sbg:revisionNotes: Copy of boris_majic/genesis-toolkit-dev/null-model-r/10
- sbg:revision: 9
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1581607916
  sbg:revisionNotes: GDS filename correction
- sbg:revision: 10
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1581613630
  sbg:revisionNotes: GDS filename correction
- sbg:revision: 11
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1593598547
  sbg:revisionNotes: 'Docker image update: 2.8.0 and null_model input excluded'
- sbg:revision: 12
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1593610311
  sbg:revisionNotes: Binomial parameter changed
- sbg:revision: 13
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1593610371
  sbg:revisionNotes: Binary required
- sbg:revision: 14
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1593610600
  sbg:revisionNotes: binomial to family
- sbg:revision: 15
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1593611103
  sbg:revisionNotes: Family
- sbg:revision: 16
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1593621760
  sbg:revisionNotes: Input descriptions updated.
- sbg:revision: 17
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1602060847
  sbg:revisionNotes: Docker 2.8.1 and SaveLogs hint
- sbg:revision: 18
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1602065070
  sbg:revisionNotes: SaveLogs hint
- sbg:revision: 19
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1602076654
  sbg:revisionNotes: Input and output descriptions
- sbg:revision: 20
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1602144144
  sbg:revisionNotes: Parameter file
- sbg:revision: 21
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1602147326
  sbg:revisionNotes: report only excluded
- sbg:revision: 22
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1602149776
  sbg:revisionNotes: SaveLogs hint
- sbg:revision: 23
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1602153513
  sbg:revisionNotes: Report only excluded
- sbg:revision: 24
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1602154432
  sbg:revisionNotes: Output eval excluded
- sbg:revision: 25
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1602505365
  sbg:revisionNotes: ''
- sbg:revision: 26
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1603281262
  sbg:revisionNotes: Family corrected
- sbg:revision: 27
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1604500553
  sbg:revisionNotes: cwltool
- sbg:revision: 28
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1604503616
  sbg:revisionNotes: arguments to arg
- sbg:revision: 29
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1604913685
  sbg:revisionNotes: Stagig
- sbg:revision: 30
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1604914595
  sbg:revisionNotes: Cwltool
- sbg:revision: 31
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1604915895
  sbg:revisionNotes: Cwltool
- sbg:revision: 32
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1604916794
  sbg:revisionNotes: cwltool
- sbg:revision: 33
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1604918840
  sbg:revisionNotes: cwltool
- sbg:revision: 34
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1604923710
  sbg:revisionNotes: Staged inputs
- sbg:revision: 35
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1604925380
  sbg:revisionNotes: Staging
- sbg:revision: 36
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1604927481
  sbg:revisionNotes: Cwltool
- sbg:revision: 37
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1604962707
  sbg:revisionNotes: Cwltool
- sbg:revision: 38
  sbg:modifiedBy: dajana_panovic
  sbg:modifiedOn: 1605004147
  sbg:revisionNotes: .path to .basename
sbg:appVersion:
- v1.1
sbg:id: boris_majic/genesis-toolkit-demo/null-model-r/38
sbg:revision: 38
sbg:revisionNotes: .path to .basename
sbg:modifiedOn: 1605004147
sbg:modifiedBy: dajana_panovic
sbg:createdOn: 1570633733
sbg:createdBy: boris_majic
sbg:project: boris_majic/genesis-toolkit-demo
sbg:sbgMaintained: false
sbg:validationErrors: []
sbg:contributors:
- boris_majic
- dajana_panovic
sbg:latestRevision: 38
sbg:publisher: sbg
sbg:content_hash: a01fd2da60f594b4a7cdd85a7ae3ae932ed876379bba266bdcdc31d174a4350d0
