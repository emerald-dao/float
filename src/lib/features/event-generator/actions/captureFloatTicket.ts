import domtoimage from 'dom-to-image';

const captureFloatTicket = async (elementToCapture: HTMLElement): Promise<File | null> => {
	try {
		const scale = 2;

		const imageBlob = await domtoimage.toBlob(elementToCapture, {
			filter: (node: Node) => (node as HTMLElement).id !== 'float-back',
			height: elementToCapture.offsetHeight * scale,
			style: {
				transform: `scale(${scale}) translate(${elementToCapture.offsetWidth / 2 / scale}px, ${
					elementToCapture.offsetHeight / 2 / scale
				}px)`
			},
			width: elementToCapture.offsetWidth * scale
		});

		return new File([imageBlob], 'float-ticket.png', { type: 'image/png' });
	} catch (error) {
		console.error('Error capturing image:', error);

		return null;
	}
};

export default captureFloatTicket;
