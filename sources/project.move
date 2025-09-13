 module MyModule::RecipeTokenization {
    use aptos_framework::signer;
    use std::string::String;
    use std::vector;

    /// Struct representing a tokenized recipe with metadata
    struct Recipe has store, key {
        name: String,           // Name of the recipe
        ingredients: String,    // List of ingredients as a string
        instructions: String,   // Cooking instructions
        creator: address,       // Original creator of the recipe
        owner: address,         // Current owner of the recipe token
        token_id: u64,         // Unique identifier for the recipe token
    }

    /// Global counter for generating unique token IDs
    struct RecipeCounter has key {
        next_id: u64,
    }

    /// Function to create and tokenize a new recipe
    public fun create_recipe_token(
        creator: &signer, 
        name: String, 
        ingredients: String, 
        instructions: String
    ) acquires RecipeCounter {
        let creator_address = signer::address_of(creator);
        
        // Initialize counter if it doesn't exist
        if (!exists<RecipeCounter>(creator_address)) {
            move_to(creator, RecipeCounter { next_id: 1 });
        };
        
        let counter = borrow_global_mut<RecipeCounter>(creator_address);
        let token_id = counter.next_id;
        counter.next_id = token_id + 1;

        // Create the recipe token
        let recipe = Recipe {
            name,
            ingredients,
            instructions,
            creator: creator_address,
            owner: creator_address,
            token_id,
        };

        move_to(creator, recipe);
    }

    /// Function to transfer recipe token ownership to another user
    public fun transfer_recipe_token(
        current_owner: &signer, 
        new_owner_signer: &signer, 
        token_id: u64
    ) acquires Recipe {
        let current_owner_address = signer::address_of(current_owner);
        let new_owner_address = signer::address_of(new_owner_signer);
        
        // Verify the recipe exists and current owner is authorized
        assert!(exists<Recipe>(current_owner_address), 1);
        
        let recipe = move_from<Recipe>(current_owner_address);
        
        // Verify ownership and token ID match
        assert!(recipe.owner == current_owner_address, 2);
        assert!(recipe.token_id == token_id, 3);
        
        // Update owner and move to new owner's account
        recipe.owner = new_owner_address;
        move_to(new_owner_signer, recipe);
    }
}