const { Resend } = require('resend');

function escapeHtml(value) {
  return String(value)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
}

module.exports = async (req, res) => {
  if (req.method !== 'POST') {
    res.status(405).json({ error: 'Method Not Allowed' });
    return;
  }

  const { name, phone, email, message } = req.body || {};

  if (!name || !phone || !email || !message) {
    res.status(400).json({ error: 'Missing required fields' });
    return;
  }

  const resend = new Resend(process.env.RESEND_API_KEY);
  const to = process.env.ADMIN_NOTIFY_EMAIL;

  try {
    await resend.emails.send({
      from: 'onboarding@resend.dev',
      to,
      subject: '[BuildOn] 새로운 상담 문의가 접수되었습니다',
      html: `
        <h2>새로운 상담 문의</h2>
        <p><strong>이름:</strong> ${escapeHtml(name)}</p>
        <p><strong>연락처:</strong> ${escapeHtml(phone)}</p>
        <p><strong>이메일:</strong> ${escapeHtml(email)}</p>
        <p><strong>문의 내용:</strong></p>
        <p>${escapeHtml(message).replace(/\n/g, '<br>')}</p>
      `,
    });
    res.status(200).json({ ok: true });
  } catch (err) {
    console.error('Resend send failed:', err);
    res.status(500).json({ error: 'Failed to send notification' });
  }
};
