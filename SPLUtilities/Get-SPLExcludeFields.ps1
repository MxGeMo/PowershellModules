function Get-SPLExcludeFields {
    $ExcludeFields =  `
    '_ComplianceFlags', `
    '_ComplianceTag', `
    '_ComplianceTagUserId', `
    '_ComplianceTagWrittenTime', `
    '_CopySource', `
    '_EditMenuTableEnd', `
    '_EditMenuTableStart', `
    '_EditMenuTableStart2', `
    '_HasCopyDestinations', `
    '_IsCurrentVersion', `
    '_IsRecord', `
    '_Level', `
    '_ModerationComments', `
    '_ModerationStatus', `
    '_UIVersion', `
    '_UIVersionString', `
    '_VirusInfo', `
    '_VirusStatus', `
    '_VirusVendorID', `
    'AccessPolicy', `
    'AppAuthor', `
    'AppEditor', `
    'Attachments', `
    # 'Author', `
    'BaseName', `
    'ComplianceAssetId', `
    'ContentType', `
    'ContentTypeId', `
    'ContentVersion', `
    # 'Created', `
    'Created_x0020_Date', `
    'DocIcon', `
    'Edit', `
    # 'Editor', `
    'EncodedAbsUrl', `
    'File_x0020_Type', `
    'FileDirRef', `
    'FileLeafRef', `
    'FileRef', `
    'FolderChildCount', `
    'FSObjType', `
    'GUID', `
    'HTML_x0020_File_x0020_Type', `
    'InstanceID', `
    # 'ID', `
    'ItemChildCount', `
    'Last_x0020_Modified', `
    'LinkFilename', `
    'LinkFilename2', `
    'LinkFilenameNoMenu', `
    'LinkTitle', `
    'LinkTitle2', `
    'LinkTitleNoMenu', `
    'MetaInfo', `
    #'Modified', `
    'NoExecute', `
    'Order', `
    'OriginatorId', `
    'owshiddenversion', `
    'PermMask', `
    'ProgId', `
    'Restricted', `
    'ScopeId', `
    'SelectTitle', `
    'ServerUrl', `
    'SMLastModifiedDate', `
    'SMTotalFileCount', `
    'SMTotalFileStreamSize', `
    'SMTotalSize', `
    'SortBehavior', `
    'SyncClientId', `
    'UniqueId', `
    'WorkflowInstanceID', `
    'WorkflowVersion'
    $ExcludeFields
}
