import 'dart:io';

/// Mensagem genérica segura
const genericErrorMessage = "'Algo deu errado. Tente novamente.'";

void main() {
  final dir = Directory.current;

  final dartFiles = dir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'));// print removido por segurança

  for (var file in dartFiles) {
    final originalContent = file.readAsStringSync();
    var updatedContent = originalContent;
    bool modified = false;

    // Substitui mensagens como: _errorMessage = 'Algo deu errado. Tente novamente.';
    updatedContent = updatedContent.replaceAllMapped(
      RegExp(r"""(_errorMessage\s*=\s*['"].*?\$\{?e\..*?}*['"];)"""),
          (match) {
        modified = true;
        return "_errorMessage = $genericErrorMessage;";
      },
    );

    // Substitui prints, mesmo se for multilinha ou aninhado
    updatedContent = updatedContent.replaceAllMapped(
      RegExp(r"""^\s*print\((.|\s)*?\);""", multiLine: true),
          (match) {
        modified = true;
        return '// print removido por segurança';
      },
    );

    if (modified) {
      // Backup do arquivo original
      final backupPath = '${file.path}.bak';
      File(backupPath).writeAsStringSync(originalContent);
      file.writeAsStringSync(updatedContent);// print removido por segurança
    }
  }// print removido por segurança// print removido por segurança
}
