export type Json = string | number | boolean | null | { [key: string]: Json | undefined } | Json[];

export interface Database {
	graphql_public: {
		Tables: {
			[_ in never]: never;
		};
		Views: {
			[_ in never]: never;
		};
		Functions: {
			graphql: {
				Args: {
					operationName?: string;
					query?: string;
					variables?: Json;
					extensions?: Json;
				};
				Returns: Json;
			};
		};
		Enums: {
			[_ in never]: never;
		};
		CompositeTypes: {
			[_ in never]: never;
		};
	};
	public: {
		Tables: {
			float_claims: {
				Row: {
					block_id: string | null;
					created_at: string | null;
					event_id: string | null;
					float_id: string;
					network: string | null;
					transaction_id: string | null;
					user_address: string;
				};
				Insert: {
					block_id?: string | null;
					created_at?: string | null;
					event_id?: string | null;
					float_id: string;
					network?: string | null;
					transaction_id?: string | null;
					user_address: string;
				};
				Update: {
					block_id?: string | null;
					created_at?: string | null;
					event_id?: string | null;
					float_id?: string;
					network?: string | null;
					transaction_id?: string | null;
					user_address?: string;
				};
				Relationships: [
					{
						foreignKeyName: 'claims_event_id_fkey';
						columns: ['event_id'];
						referencedRelation: 'float_events';
						referencedColumns: ['id'];
					}
				];
			};
			float_events: {
				Row: {
					created_at: string | null;
					creator_address: string;
					id: string;
					network: string | null;
				};
				Insert: {
					created_at?: string | null;
					creator_address: string;
					id: string;
					network?: string | null;
				};
				Update: {
					created_at?: string | null;
					creator_address?: string;
					id?: string;
					network?: string | null;
				};
				Relationships: [];
			};
			float_floats_groups: {
				Row: {
					float_id: string;
					group_id: number;
				};
				Insert: {
					float_id: string;
					group_id: number;
				};
				Update: {
					float_id?: string;
					group_id?: number;
				};
				Relationships: [
					{
						foreignKeyName: 'floats_groups_group_id_fkey';
						columns: ['group_id'];
						referencedRelation: '';
						referencedColumns: ['id'];
					}
				];
			};
			: {
				Row: {
					created_at: string;
					description: string | null;
					id: number;
					name: string;
					user_address: string;
				};
				Insert: {
					created_at?: string;
					description?: string | null;
					id?: number;
					name: string;
					user_address: string;
				};
				Update: {
					created_at?: string;
					description?: string | null;
					id?: number;
					name?: string;
					user_address?: string;
				};
				Relationships: [];
			};
			float_pinned_floats: {
				Row: {
					float_id: string;
					network: string | null;
					user_address: string;
				};
				Insert: {
					float_id: string;
					network?: string | null;
					user_address: string;
				};
				Update: {
					float_id?: string;
					network?: string | null;
					user_address?: string;
				};
				Relationships: [];
			};
		};
		Views: {
			[_ in never]: never;
		};
		Functions: {
			[_ in never]: never;
		};
		Enums: {
			[_ in never]: never;
		};
		CompositeTypes: {
			[_ in never]: never;
		};
	};
	storage: {
		Tables: {
			buckets: {
				Row: {
					allowed_mime_types: string[] | null;
					avif_autodetection: boolean | null;
					created_at: string | null;
					file_size_limit: number | null;
					id: string;
					name: string;
					owner: string | null;
					public: boolean | null;
					updated_at: string | null;
				};
				Insert: {
					allowed_mime_types?: string[] | null;
					avif_autodetection?: boolean | null;
					created_at?: string | null;
					file_size_limit?: number | null;
					id: string;
					name: string;
					owner?: string | null;
					public?: boolean | null;
					updated_at?: string | null;
				};
				Update: {
					allowed_mime_types?: string[] | null;
					avif_autodetection?: boolean | null;
					created_at?: string | null;
					file_size_limit?: number | null;
					id?: string;
					name?: string;
					owner?: string | null;
					public?: boolean | null;
					updated_at?: string | null;
				};
				Relationships: [
					{
						foreignKeyName: 'buckets_owner_fkey';
						columns: ['owner'];
						referencedRelation: 'users';
						referencedColumns: ['id'];
					}
				];
			};
			migrations: {
				Row: {
					executed_at: string | null;
					hash: string;
					id: number;
					name: string;
				};
				Insert: {
					executed_at?: string | null;
					hash: string;
					id: number;
					name: string;
				};
				Update: {
					executed_at?: string | null;
					hash?: string;
					id?: number;
					name?: string;
				};
				Relationships: [];
			};
			objects: {
				Row: {
					bucket_id: string | null;
					created_at: string | null;
					id: string;
					last_accessed_at: string | null;
					metadata: Json | null;
					name: string | null;
					owner: string | null;
					path_tokens: string[] | null;
					updated_at: string | null;
					version: string | null;
				};
				Insert: {
					bucket_id?: string | null;
					created_at?: string | null;
					id?: string;
					last_accessed_at?: string | null;
					metadata?: Json | null;
					name?: string | null;
					owner?: string | null;
					path_tokens?: string[] | null;
					updated_at?: string | null;
					version?: string | null;
				};
				Update: {
					bucket_id?: string | null;
					created_at?: string | null;
					id?: string;
					last_accessed_at?: string | null;
					metadata?: Json | null;
					name?: string | null;
					owner?: string | null;
					path_tokens?: string[] | null;
					updated_at?: string | null;
					version?: string | null;
				};
				Relationships: [
					{
						foreignKeyName: 'objects_bucketId_fkey';
						columns: ['bucket_id'];
						referencedRelation: 'buckets';
						referencedColumns: ['id'];
					}
				];
			};
		};
		Views: {
			[_ in never]: never;
		};
		Functions: {
			can_insert_object: {
				Args: {
					bucketid: string;
					name: string;
					owner: string;
					metadata: Json;
				};
				Returns: undefined;
			};
			extension: {
				Args: {
					name: string;
				};
				Returns: string;
			};
			filename: {
				Args: {
					name: string;
				};
				Returns: string;
			};
			foldername: {
				Args: {
					name: string;
				};
				Returns: unknown;
			};
			get_size_by_bucket: {
				Args: Record<PropertyKey, never>;
				Returns: {
					size: number;
					bucket_id: string;
				}[];
			};
			search: {
				Args: {
					prefix: string;
					bucketname: string;
					limits?: number;
					levels?: number;
					offsets?: number;
					search?: string;
					sortcolumn?: string;
					sortorder?: string;
				};
				Returns: {
					name: string;
					id: string;
					updated_at: string;
					created_at: string;
					last_accessed_at: string;
					metadata: Json;
				}[];
			};
		};
		Enums: {
			[_ in never]: never;
		};
		CompositeTypes: {
			[_ in never]: never;
		};
	};
}
