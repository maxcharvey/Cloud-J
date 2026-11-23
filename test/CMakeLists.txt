if(WIN32)
  add_test(NAME GenerateOutput
    COMMAND ${CMAKE_COMMAND} -E env cmd /c "$<TARGET_FILE:cloudj_standalone> > actual_output.txt"
    WORKING_DIRECTORY ${PROJECT_BINARY_DIR}/bin
  )

  add_test(NAME CompareOutput
    COMMAND ${CMAKE_COMMAND} -E compare_files --ignore-eol actual_output.txt "${CMAKE_SOURCE_DIR}/test/expected_output/reference_output.txt"
    WORKING_DIRECTORY ${PROJECT_BINARY_DIR}/bin
  )
  set_tests_properties(CompareOutput PROPERTIES DEPENDS GenerateOutput)
else()
  add_test(NAME CompareOutput
    COMMAND ${CMAKE_COMMAND} -E env sh -c "$<TARGET_FILE:cloudj_standalone> > actual_output.txt; ${CMAKE_COMMAND} -E compare_files --ignore-eol actual_output.txt ${CMAKE_SOURCE_DIR}/test/expected_output/reference_output.txt"
    WORKING_DIRECTORY ${PROJECT_BINARY_DIR}/bin
  )
endif()

if(NOT CLOUDJ_EXTERNAL_CONFIG)
  add_executable(cloudj_aerosol_reader_test aerosol_reader.F90)
  target_link_libraries(cloudj_aerosol_reader_test PRIVATE CloudJ_Core)
  set(aerosol_reader_tables "${PROJECT_BINARY_DIR}/test/aerosol_reader/tables")
  add_test(NAME PrepareAerosolReaderTables
    COMMAND ${CMAKE_COMMAND} -E copy_directory
      "${PROJECT_SOURCE_DIR}/tables" "${aerosol_reader_tables}"
  )
  set_tests_properties(PrepareAerosolReaderTables PROPERTIES FIXTURES_SETUP AerosolReaderTables)
  add_test(NAME AerosolReader
    COMMAND cloudj_aerosol_reader_test "${PROJECT_SOURCE_DIR}/tables" "${aerosol_reader_tables}"
  )
  set_tests_properties(AerosolReader PROPERTIES FIXTURES_REQUIRED AerosolReaderTables)
endif()
