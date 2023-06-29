import QRCode from 'qrcode';

let opts = {
	errorCorrectionLevel: 'M',
	scale: 6,
	margin: 1
};

async function generateQRCode(value: string): Promise<string> {
	try {
		return await QRCode.toDataURL(value, opts);
	} catch (error) {
		console.error('QR code generation error:', error);
		return '';
	}
}

export default generateQRCode;
