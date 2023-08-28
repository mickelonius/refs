from typing import Dict
from pydantic import BaseModel, Field

class MandatoryModel(BaseModel):
    id: int
    name: str
    other_id_data: Dict = Field(default_factory=dict)

# Start by creating a base Pydantic model that has a dictionary
# with any keys and values.
class DynamicModel(BaseModel):
    key_data: MandatoryModel
    data: Dict

    def get_data_field(self, field_name):
        return self.data.get(field_name)

# When you receive JSON data, you can parse it into
# the base model. This way, you can store the inconsistent
# fields in the data dictionary.
json_data = {
    "key_data": {
        "id": 1234,
        "name": "some datuz",
    },
    "data": {
        "key1": "value1",
        "field2": 42,
        "field3": ["item1", "item2"],
    }
}

dynamic_model = DynamicModel(**json_data)
print(dynamic_model.get_data_field("field1"))  # Output: value1

# You can still access and validate fields using the data dictionary
# attribute of the model. You can also define additional validation
# rules for the fields within the dictionary.
# Access fields
print(dynamic_model.data.get("field1"))  # Output: value1
print(dynamic_model.data.get("field2"))  # Output: 42

###############################################################
# Validate fields
###############################################################

# missing key_data
from pydantic import ValidationError
try:
    DynamicModel(id=1234, name="some_data", data={"invalid_field": "value"})
except ValidationError as e:
    print(e)

# missing name for key_data
try:
    DynamicModel(key_data={"id": 1234,}, data={"invalid_field": "value"})
except ValidationError as e:
    print(e)

# default value in MandatoryModel
try:
    DynamicModel(
        key_data={"id": 1234, "name": "datuz"},
        data={"invalid_field": "value"}
    )
except ValidationError as e:
    print(e)
