use obi::{OBIDecode, OBIEncode, OBISchema};
use owasm_kit::{execute_entry_point, ext, oei, prepare_entry_point};

#[derive(OBIDecode, OBISchema)]
struct Input {
    flight: String,
    iso_date: String,
}

#[derive(OBIEncode, OBISchema, Eq, PartialEq)]
struct Output {
    status: String,
    arrival_airport: String,
    scheduled_time_utc: String,
    actual_time_utc: String,
}

// Replace with the correct Data Source id, after deploying them
const PYTHON_DATA_SOURCE_ID: i64 = 323;

const PYTHON_EXTERNAL_ID: i64 = 0;

#[no_mangle]
fn prepare_impl(input: Input) {

    oei::ask_external_data(
        PYTHON_EXTERNAL_ID,
        PYTHON_DATA_SOURCE_ID,
        format!("{} {}", input.flight, input.iso_date).as_bytes(),
    );
}

#[no_mangle]
fn execute_impl(_input: Input) -> Output {
    let python_result = ext::load_majority::<String>(PYTHON_EXTERNAL_ID).unwrap();

    let python_output = parse_result(python_result);

    return python_output
}

// Results are comma-sparated values (no spaces)
// Flight Status, Arrival airport, Scheduled Time UTC, Actual Time UTC
fn parse_result(result: String) -> Output {
    let vec: Vec<&str> = result.split(",").collect();

    Output {
        status: vec[0].to_string(),
        arrival_airport: vec[1].to_string(),
        scheduled_time_utc: vec[2].to_string(),
        actual_time_utc: vec[3].to_string()
    }
}

prepare_entry_point!(prepare_impl);
execute_entry_point!(execute_impl);
