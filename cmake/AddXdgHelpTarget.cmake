#
# Functions to install the docbook xml sources for use with gnome help
#
# Paremeters:
# - docname: basename of the main xml file. Will be used to locate
#            this primary xml file and for various output files/directories
# - lang: language of the current document
# - entities: list of all xml files this document is composed of
# - figdir: name of the directory holding the images

function (add_xdghelp_target docname lang entities figures)

    set(BUILD_DIR "${DATADIR_BUILD}/help/${lang}/${docname}")

    set(source_files "")
    foreach(xml_file ${entities} index.docbook)
        list(APPEND source_files "${CMAKE_CURRENT_SOURCE_DIR}/${xml_file}")
    endforeach()

    set(dtd_files "${CMAKE_SOURCE_DIR}/docbook/gnc-docbookx.dtd"
                  "${CMAKE_SOURCE_DIR}/docbook/gnc-gui-struct.dtd"
                  "${CMAKE_SOURCE_DIR}/docbook/gnc-gui-C.dtd"
                  "${CMAKE_SOURCE_DIR}/docbook/gnc-gui-${lang}.dtd")
    list(REMOVE_DUPLICATES dtd_files)
    list(APPEND source_files ${dtd_files})

    set(dest_files "")
    foreach(xml_file ${entities} index.docbook gnc-docbookx.dtd)
        list(APPEND dest_files "${BUILD_DIR}/${xml_file}")
    endforeach()

    add_custom_command(
      OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/xdghelptrigger"
      COMMAND ${CMAKE_COMMAND} -E make_directory "${BUILD_DIR}"
      COMMAND ${CMAKE_COMMAND} -E make_directory "${BUILD_DIR}/figures"
      COMMAND touch "${CMAKE_CURRENT_BINARY_DIR}/xdghelptrigger")


    add_custom_command(
        OUTPUT ${dest_files}
        COMMAND ${CMAKE_COMMAND} -E copy ${source_files} "${BUILD_DIR}"
        DEPENDS ${entities} "index.docbook" ${dtd_files} "${CMAKE_CURRENT_BINARY_DIR}/xdghelptrigger"
        WORKING_DIRECTORY "${BUILD_DIR}")

    # Copy figures for this document
    set(source_figures "")
    foreach(figure ${figures})
        list(APPEND source_figures "${CMAKE_CURRENT_SOURCE_DIR}/${figure}")
    endforeach()

    set(dest_figures "")
    foreach(figure ${figures})
        list(APPEND dest_figures "${BUILD_DIR}/${figure}")
    endforeach()

    if(dest_figures)
        add_custom_command(
            OUTPUT ${dest_figures}
            COMMAND ${CMAKE_COMMAND} -E copy ${source_figures} "${BUILD_DIR}/figures"
            DEPENDS ${source_figures} "${CMAKE_CURRENT_BINARY_DIR}/xdghelptrigger")
    endif()

    add_custom_target("${lang}-${docname}-xdghelp"
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/xdghelptrigger"
                 ${dest_files} ${dest_figures})

    add_dependencies(${docname}-xdghelp "${lang}-${docname}-xdghelp")

    install(FILES ${source_files}
        DESTINATION "${CMAKE_INSTALL_DATADIR}/help/${lang}/${docname}"
        COMPONENT "xdghelp")
    install(FILES ${figures}
        DESTINATION "${CMAKE_INSTALL_DATADIR}/help/${lang}/${docname}/figures"
        COMPONENT "xdghelp")
endfunction()
