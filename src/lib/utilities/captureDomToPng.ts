import domtoimage from 'dom-to-image';

const captureDomToPng = async (
	elementToCapture: HTMLElement | null,
	poweredByStyle: HTMLElement | null,
	titleStyle: HTMLElement | null
) => {
	if (poweredByStyle && titleStyle) {
		poweredByStyle.style.textAlign = 'end';
		poweredByStyle.style.width = '100%';
		titleStyle.style.width = '90%';
	}

	try {
		if (elementToCapture) {
			elementToCapture.style.width = '600px';
			elementToCapture.style.background = 'transparent';
		}

		const dataUrl = await domtoimage.toPng(elementToCapture, {
			filter: (node: HTMLElement) => node.id !== 'element-to-exclude'
		});

		if (elementToCapture && poweredByStyle && titleStyle) {
			elementToCapture.style.width = '';
			poweredByStyle.style.textAlign = '';
			poweredByStyle.style.width = '';
			titleStyle.style.width = '';
		}

		console.log(dataUrl);
		return dataUrl;
	} catch (error) {
		console.error('Error capturing image:', error);

		if (poweredByStyle && titleStyle) {
			poweredByStyle.style.backgroundColor = '';
			poweredByStyle.style.color = '';
			titleStyle.style.width = '';
		}

		return null;
	}
};

export default captureDomToPng;
