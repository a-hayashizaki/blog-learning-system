document.addEventListener('DOMContentLoaded', function() {
  const generateBtn = document.getElementById('generate-article-btn');
  
  if (generateBtn) {
    generateBtn.addEventListener('click', async function(event) {
      event.preventDefault();
      
      const memo = document.getElementById('article_original_memo').value;
      const theme = document.getElementById('article_theme').value;
      const ratio = document.getElementById('article_experience_ratio').value;
      const casual = document.getElementById('article_casualness_level').value;
      const structure = document.getElementById('article_structure_type').value;

      if (!memo.trim()) {
        alert('気づきメモを入力してください');
        return;
      }

      if (!theme) {
        alert('テーマを選択してください');
        return;
      }

      const button = event.target;
      const originalText = button.textContent;
      button.textContent = '生成中...';
      button.disabled = true;

      try {
        const response = await fetch('/articles/generate', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
          },
          body: JSON.stringify({
            original_memo: memo,
            theme: theme,
            experience_ratio: parseFloat(ratio) || 0.5,
            casualness_level: parseInt(casual) || 3,
            structure_type: structure || 'standard'
          })
        });

        const data = await response.json();

        if (response.ok) {
          document.getElementById('article_title').value = data.title;
          document.getElementById('article_content').value = data.content;
          alert('記事が生成されました！');
        } else {
          alert('記事生成エラー: ' + (data.error || '不明なエラー'));
        }
      } catch (error) {
        alert('通信エラー: ' + error.message);
      } finally {
        button.textContent = originalText;
        button.disabled = false;
      }
    });
  }
});