import { writable } from 'svelte/store';

const createFetchStore = <T>(fetchFuncion: () => Promise<T>, defaultData: T) => {
	let data: T = defaultData;

	const { subscribe, set } = writable(data);

	const fetchData = () => {
		fetchFuncion().then((res) => {
			set(res);
		});
	};

	fetchData();

	return {
		subscribe,
		invalidate: fetchData
	};
};

export default createFetchStore;
