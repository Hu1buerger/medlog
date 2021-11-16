### TODO:

#### Dataloading / writing

- Replace the old SharedPreferences data store
    for that we would need to 
        - load the Json 
            - done by JsonStore
        - access the KV-Pair from the Controller (rename to DataRepo)
            - in that step the serialized data unit needs to be converted to the obj. representation
            - 2 cases
                1. the Value is one obj => i.e. String
                2. the value is a list => i.e. List<Pharmaceutical>

- Other issue `rehydration`

- following architecture
    - Repo =Load=> TypeAdapter =LoadJson=> JsonStore

- The repo asks for a complex datatype.
    i.e. a list of R or R 

### Facade 
I do want to hide the complexity of loading the data, selecting the right Adapter.

The reason i do want to do that is for replacability and bcs i do have data on a device for personal testing,
that contains some interval of data.

Therefore the Facade should load from 

SharedPreferences 
    - using the old tooling

and from JsonStore 
    - using the new loadingmechanism.

