const EXTENSIONS_TO_MIME_TYPES = {
  'csv': 'text/csv',
  'xls': 'application/vnd.ms-excel',
  'xlsx': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  'pdf': 'application/pdf'
}

export function fileExtToMimeType(extension) {
  const extensionWithoutDot = extension.split('.').filter(ext => !!ext)[0];

  return EXTENSIONS_TO_MIME_TYPES[extensionWithoutDot];
}
