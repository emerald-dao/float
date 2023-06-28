import domtoimage from 'dom-to-image';

const captureDomToPng = async (
	elementToCapture: HTMLElement | null,
	partToStyle: HTMLElement | null
) => {
	if (partToStyle) {
		partToStyle.style.textAlign = 'end';
		partToStyle.style.width = '100%';
	}

	try {
		const dataUrl = await domtoimage.toPng(elementToCapture, {
			filter: (node: HTMLElement) => node.id !== 'element-to-exclude'
		});

		if (partToStyle) {
			partToStyle.style.backgroundColor = '';
			partToStyle.style.color = '';
		}

		return dataUrl;
	} catch (error) {
		console.error('Error capturing image:', error);

		if (partToStyle) {
			partToStyle.style.backgroundColor = '';
			partToStyle.style.color = '';
		}

		return null;
	}
};

export default captureDomToPng;

/* 
Code needed to execute this function in some Svelte component: 

import captureDomToPng from '$lib/utilities/captureDomToPng';

let capturedImageSrc: string;

const elementToCapture = document.getElementById('targetElement');
const partToStyle = document.getElementById('part-to-style');

async function handleCaptureClick() {
	capturedImageSrc = await captureDomToPng(elementToCapture, partToStyle);
}
    
*/
