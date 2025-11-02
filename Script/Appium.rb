#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

# Script simple para abrir Mercado Libre en Android
# Autor: Oliver Olvera
# Fecha: 2024
# Descripción: Abre la aplicación de Mercado Libre en dispositivo Android y busca "playstation 5"

require 'appium_lib'
require 'logger'
require 'colorize'

class MercadoLibreAppOpener
  def initialize
    @logger = Logger.new(STDOUT)
    @logger.level = Logger::DEBUG  # Cambiar a DEBUG para ver más información
    @driver = nil
  end

  # Configuración de las Desired Capabilities para Android
  def setup_desired_capabilities
    {
      platformName: 'Android',
      'appium:deviceName': 'Android Emulator',
      'appium:udid': 'emulator-5554',
      'appium:appPackage': 'com.mercadolibre',
      'appium:appActivity': 'com.mercadolibre.splash.SplashActivity',
      'appium:automationName': 'UiAutomator2',
      'appium:newCommandTimeout': 300,
      'appium:noReset': true,
      'appium:fullReset': false,
      'appium:autoGrantPermissions': true,
      'appium:skipServerInstallation': false,
      'appium:skipDeviceInitialization': true,
      'appium:disableIdLocatorAutocompletion': false,
      'appium:skipUnlock': true
    }
  end

  # Inicializar la sesión de Appium
  def start_session
    caps = setup_desired_capabilities
    server_url = 'http://localhost:4723'

    begin
      @core = Appium::Core.for(capabilities: caps)
      @driver = @core.start_driver(server_url: server_url)
      return true
    rescue => e
      @logger.error("/// Error al iniciar sesión de Appium: #{e.message}".colorize(:red))
      return false
    end
  end

  # Abrir la aplicación de Mercado Libre
  def open_mercado_libre
    begin
      sleep(3)
      current_activity = @driver.current_activity

      if current_activity.include?('Launcher') || current_activity.include?('NexusLauncher')
        @driver.activate_app('com.mercadolibre')
        sleep(3)
      end

      @logger.info("==> Mercado Libre abierto correctamente".colorize(:green))
      sleep(2)
      return true

    rescue => e
      @logger.error("/// Error al abrir Mercado Libre: #{e.message}".colorize(:red))
      return false
    end
  end

  # Buscar un producto en la barra de búsqueda
  def search_item(search_term)
    begin
      # Paso 1: Hacer clic en la toolbar para activar la búsqueda
      toolbar = @driver.find_element({ id: 'com.mercadolibre:id/ui_components_toolbar_title_toolbar' })
      toolbar.click
      sleep(2)

      # Paso 2: Buscar el campo de búsqueda
      search_locators = [
        { id: 'com.mercadolibre:id/autosuggest_input_search' },
        { xpath: "//android.widget.EditText[contains(@hint, 'Buscar')]" },
        { xpath: "//android.widget.AutoCompleteTextView" }
      ]

      search_field = nil
      search_locators.each do |locator|
        begin
          search_field = @driver.find_element(locator)
          break
        rescue
        end
      end

      unless search_field
        @logger.error("/// No se pudo encontrar la barra de búsqueda".colorize(:red))
        return false
      end

      # Paso 3: Escribir en el campo
      search_field.click
      sleep(1)
      search_field.clear
      search_field.send_keys(search_term)
      sleep(1)

      # Paso 4: Ejecutar la búsqueda
      search_button_locators = [
        { xpath: "//android.widget.Button[contains(@text, 'Buscar')]" },
        { xpath: "//android.widget.ImageButton[contains(@content-desc, 'Buscar')]" },
        { id: 'com.mercadolibre:id/search_button' }
      ]

      search_button = nil
      search_button_locators.each do |locator|
        begin
          search_button = @driver.find_element(locator)
          break
        rescue
        end
      end

      if search_button
        search_button.click
      else
        @driver.press_keycode(66) # Enter
      end

      sleep(3)
      @logger.info("==> Búsqueda realizada correctamente".colorize(:green))
      return true

    rescue => e
      @logger.error("/// Error al buscar: #{e.message}".colorize(:red))
      return false
    end
  end

  # Hacer clic en el botón de filtros
  def click_filters_button
    begin
      sleep(2) # Esperar a que carguen los resultados

      # Estrategia 1: Buscar el LinearLayout padre que contiene el TextView con texto que comienza con "Filtro"
      # Este LinearLayout debería ser clickable
      filter_locators = [
        # Buscar el LinearLayout padre que contiene un TextView con texto que comienza con "Filtro"
        { xpath: "//android.widget.LinearLayout[.//android.widget.TextView[starts-with(@text, 'Filtro')]]" },
        { xpath: "//android.widget.LinearLayout[.//android.widget.TextView[contains(@text, 'Filtro')]]" },
        # Buscar directamente por el texto usando el padre
        { xpath: "//android.widget.TextView[starts-with(@text, 'Filtro')]/parent::android.widget.LinearLayout" },
        { xpath: "//android.widget.TextView[contains(@text, 'Filtro')]/parent::android.widget.LinearLayout" },
        # Buscar el ImageView del icono dentro del LinearLayout
        { xpath: "//android.widget.LinearLayout[.//android.widget.TextView[starts-with(@text, 'Filtro')]]//android.widget.ImageView" },
        # Buscar por content-desc del RecyclerView padre
        { xpath: "//androidx.recyclerview.widget.Recycler[@content-desc='Filtros más usados']//android.widget.LinearLayout[.//android.widget.TextView[starts-with(@text, 'Filtro')]]" }
      ]

      filter_button = nil
      filter_locators.each do |locator|
        begin
          filter_button = @driver.find_element(locator)
          break
        rescue => e
          # Continuar con el siguiente localizador
        end
      end

      unless filter_button
        @logger.error("/// No se pudo encontrar el botón de filtros".colorize(:red))
        return false
      end

      # Intentar hacer clic (aunque el elemento indique clickable=false, puede funcionar)
      begin
        filter_button.click
      rescue => e
        # Si falla, intentar hacer clic por coordenadas usando TouchAction
        begin
          location = filter_button.location
          size = filter_button.size
          x = location.x + (size.width / 2)
          y = location.y + (size.height / 2)

          # Usar tap de Appium
          @driver.execute_script("mobile: tap", { x: x, y: y })
        rescue => e2
          @logger.error("/// Error al hacer clic en filtros: #{e2.message}".colorize(:red))
          return false
        end
      end

      sleep(2)
      return true

    rescue => e
      @logger.error("/// Error al abrir filtros: #{e.message}".colorize(:red))
      return false
    end
  end

  # Hacer scroll en el contenedor de filtros hasta arriba
  def scroll_container_to_top
    begin
      max_scrolls = 2  # Solo 2 scrolls son necesarios
      scroll_count = 0

      while scroll_count < max_scrolls
        # Usar mobile: swipeGesture con la sintaxis correcta
        # left, top, width, height definen el área del swipe
        # direction: "down" para mover contenido hacia arriba (swipe hacia abajo)
        @driver.execute_script("mobile: swipeGesture", {
          "left" => 150,
          "top" => 1000,
          "width" => 1,
          "height" => 1000,
          "direction" => "down",
          "percent" => 1.0,
          "speed" => 500
        })
        sleep(0.4)
        scroll_count += 1
      end

      sleep(1)
      return true
    rescue => e
      @logger.error("/// Error en scroll_container_to_top: #{e.message}".colorize(:red))
      return false
    end
  end

  # Navegar hacia un selectable específico verificando selectables intermedios uno por uno
  def navigate_to_selectable(target_selectable_id)
    begin
      # Obtener el número del selectable objetivo
      target_num = target_selectable_id.to_s.gsub('selectable-', '').to_i

      # Determinar posición actual
      current_num = nil

      # Buscar selectables visibles para determinar posición actual
      (4..21).each do |i|
        begin
          element = @driver.find_element({ id: "selectable-#{i}" })
          if element && element.displayed?
            current_num = i
            break
          end
        rescue
        end
      end

      # Si no encontramos ninguno, empezar desde selectable-11 (que siempre está renderizado)
      unless current_num
        current_num = 11
      end

      # Si ya estamos en el target, retornarlo directamente
      if current_num == target_num
        begin
          target_element = @driver.find_element({ id: target_selectable_id })
          return target_element if target_element && target_element.displayed?
        rescue
        end
      end

      # Navegar verificando selectables intermedios uno por uno
      if target_num > current_num
        # Ir hacia abajo: verificar selectables desde current_num+1 hasta target_num
        (current_num + 1..target_num).each do |i|
          max_attempts = 5
          attempts = 0

          while attempts < max_attempts
            begin
              element = @driver.find_element({ id: "selectable-#{i}" })
              if element && element.displayed?
                # Si encontramos el target, retornarlo
                if i == target_num
                  return element
                end
                # Si encontramos un intermedio, continuar al siguiente
                break
              end
            rescue
            end

            # Si no está visible, hacer scroll hacia abajo (swipe hacia arriba: de abajo hacia arriba)
            window_size = @driver.window_size
            start_x = window_size.width / 2
            start_y = window_size.height * 0.7
            end_y = window_size.height * 0.3

            begin
              # Swipe hacia arriba (de abajo hacia arriba) para mover contenido hacia abajo
              @driver.swipe(start_x: start_x, start_y: start_y, end_x: start_x, end_y: end_y, duration: 500)
            rescue
              # direction: "up" para mover contenido hacia abajo
              @driver.execute_script("mobile: scroll", { direction: "up" })
            end

            sleep(0.5)
            attempts += 1
          end
        end
      elsif target_num < current_num
        # Ir hacia arriba: verificar selectables desde current_num-1 hasta target_num
        (current_num - 1).downto(target_num).each do |i|
          max_attempts = 5
          attempts = 0

          while attempts < max_attempts
            begin
              element = @driver.find_element({ id: "selectable-#{i}" })
              if element && element.displayed?
                # Si encontramos el target, retornarlo
                if i == target_num
                  return element
                end
                # Si encontramos un intermedio, continuar al siguiente
                break
              end
            rescue
            end

            # Si no está visible, hacer scroll hacia arriba (swipe hacia abajo: de arriba hacia abajo)
            window_size = @driver.window_size
            start_x = window_size.width / 2
            start_y = window_size.height * 0.3
            end_y = window_size.height * 0.7

            begin
              # Swipe hacia abajo (de arriba hacia abajo) para mover contenido hacia arriba
              @driver.swipe(start_x: start_x, start_y: start_y, end_x: start_x, end_y: end_y, duration: 500)
            rescue
              # direction: "down" para mover contenido hacia arriba
              @driver.execute_script("mobile: scroll", { direction: "down" })
            end

            sleep(0.5)
            attempts += 1
          end
        end
      end

      # Último intento de encontrar el elemento objetivo
      begin
        target_element = @driver.find_element({ id: target_selectable_id })
        return target_element if target_element && target_element.displayed?
      rescue
      end

      return nil
    rescue => e
      return nil
    end
  end

  # Aplicar filtro de Condición -> "Nuevo" (selectable-4)
  def apply_condition_filter
    begin
      # Paso 1: Hacer scroll en el contenedor root-app hasta arriba
      scroll_container_to_top
      sleep(1)

      # Paso 1.5: Verificar si selectable-4 está visible, si no, hacer más scrolls
      max_additional_scrolls = 10
      additional_scroll_count = 0
      condition_category = nil

      while additional_scroll_count < max_additional_scrolls
        # Buscar selectable-4
        condition_category_locators = [
          { id: 'selectable-4' },
          { xpath: "(//android.widget.TextView[@text='Condición'])[1]" },
          { xpath: "//android.widget.TextView[@text='Condición']" }
        ]

        condition_category_locators.each do |locator|
          begin
            found_element = @driver.find_element(locator)
            if found_element && found_element.displayed?
              condition_category = found_element
              break
            end
          rescue
          end
        end

        # Si encontramos el elemento, salir del loop
        break if condition_category

        # Si no lo encontramos, hacer scroll adicional
        begin
          @driver.execute_script("mobile: swipeGesture", {
            "left" => 150,
            "top" => 1000,
            "width" => 1,
            "height" => 1000,
            "direction" => "down",
            "percent" => 1.0,
            "speed" => 500
          })
        rescue
          # Swipe hacia abajo (de arriba hacia abajo) para mover contenido hacia arriba
          @driver.swipe(start_x: 150, start_y: 1000, end_x: 150, end_y: 2000, duration: 500)
        end
        sleep(0.5)
        additional_scroll_count += 1
      end

      # Paso 2: Verificar si finalmente encontramos la categoría
      unless condition_category
        @logger.error("/// No se pudo encontrar la categoría 'Condición'".colorize(:red))
        return false
      end

      condition_category.click
      sleep(2) # Esperar a que se rendericen las opciones

      # Paso 2: Buscar y seleccionar la opción "Nuevo" (ToggleButton)
      nuevo_locators = [
        { xpath: "//android.widget.ToggleButton[@text='Nuevo']" },
        { xpath: "//android.widget.ToggleButton[contains(@resource-id, 'ITEM_CONDITION') and @text='Nuevo']" },
        { xpath: "//*[@text='Nuevo']" }
      ]

      nuevo_option = nil
      nuevo_locators.each do |locator|
        begin
          nuevo_option = @driver.find_element(locator)
          break
        rescue
        end
      end

      unless nuevo_option
        @logger.error("/// No se pudo encontrar la opción 'Nuevo'".colorize(:red))
        return false
      end

      nuevo_option.click
      sleep(1)
      @logger.info("==> Filtro 'Nuevo' aplicado correctamente".colorize(:green))
      return true

    rescue => e
      @logger.error("/// Error al aplicar filtro de Condición: #{e.message}".colorize(:red))
      return false
    end
  end

  # Aplicar filtro de Envíos -> "Local" (selectable-9)
  def apply_shipping_filter
    begin
      # Paso 1: Buscar selectable-9 directamente primero
      shipping_category = nil
      shipping_category_locators = [
        { id: 'selectable-9' },
        { xpath: "(//android.widget.TextView[@text='Envíos'])[1]" },
        { xpath: "//android.view.View[@content-desc='Envíos']" }
      ]

      # Buscar el elemento primero
      shipping_category_locators.each do |locator|
        begin
          found_element = @driver.find_element(locator)
          if found_element && found_element.displayed?
            shipping_category = found_element
            break
          end
        rescue
        end
      end

      # Si no está visible, hacer scroll hacia arriba (ya que venimos del scroll inicial)
      # Solo 2 scrolls son necesarios
      max_scrolls = 2
      scroll_count = 0

      while !shipping_category && scroll_count < max_scrolls
        # Hacer scroll hacia arriba (swipe hacia abajo: de arriba hacia abajo)
        begin
          @driver.execute_script("mobile: swipeGesture", {
            "left" => 150,
            "top" => 1000,
            "width" => 1,
            "height" => 1000,
            "direction" => "down",
            "percent" => 1.0,
            "speed" => 500
          })
        rescue
          window_size = @driver.window_size
          start_x = window_size.width / 2
          start_y = window_size.height * 0.3
          end_y = window_size.height * 0.7
          # Swipe hacia abajo (de arriba hacia abajo) para mover contenido hacia arriba
          @driver.swipe(start_x: start_x, start_y: start_y, end_x: start_x, end_y: end_y, duration: 500)
        end

        sleep(0.5)

        # Buscar el elemento después del scroll
        shipping_category_locators.each do |locator|
          begin
            found_element = @driver.find_element(locator)
            if found_element && found_element.displayed?
              shipping_category = found_element
              break
            end
          rescue
          end
        end

        break if shipping_category
        scroll_count += 1
      end

      # Si aún no lo encontramos, intentar con navigate_to_selectable como fallback
      unless shipping_category
        shipping_category = navigate_to_selectable('selectable-9')
      end

      unless shipping_category
        @logger.error("/// No se pudo encontrar la categoría 'Envíos'".colorize(:red))
        return false
      end

      shipping_category.click
      sleep(2) # Esperar a que se rendericen las opciones

      # Paso 2: Buscar y hacer clic en la opción "Local"
      shipping_locators = [
        { xpath: "//android.widget.ToggleButton[@text='Local']" },
        { xpath: "//android.view.View[@text='Local']" },
        { xpath: "//android.view.View[@content-desc='Local']" },
        { xpath: "//android.widget.TextView[@text='Local']" },
        { id: 'selectable-9' },
        { xpath: "//*[@text='Local']" }
      ]

      shipping_option = nil
      shipping_locators.each do |locator|
        begin
          shipping_option = @driver.find_element(locator)
          break
        rescue
        end
      end

      unless shipping_option
        @logger.error("/// No se pudo encontrar la opción 'Local'".colorize(:red))
        return false
      end

      shipping_option.click
      sleep(1)
      @logger.info("==> Filtro 'Local' aplicado correctamente".colorize(:green))
      return true

    rescue => e
      @logger.error("/// Error al aplicar filtro de Envíos: #{e.message}".colorize(:red))
      return false
    end
  end

  # Aplicar filtro de Ordenar por -> "Mayor precio" (selectable-21)
  def apply_sort_filter
    begin
      # Paso 1: Hacer 3 scrolls hacia abajo sin buscar entre ellos
      (1..3).each do |i|
        @driver.execute_script("mobile: swipeGesture", {
          "left" => 150,
          "top" => 1000,
          "width" => 1,
          "height" => 1100,
          "direction" => "up",
          "percent" => 1.0,
          "speed" => 500
        })
        sleep(0.5)
      end

      sleep(1)

      # Paso 2: Buscar selectable-21 (por ID o content-desc)
      sort_category_clickable = nil

      # Buscar por content-desc primero (ya que sabemos que funciona)
      begin
        sort_category_clickable = @driver.find_element({ xpath: "//android.view.View[@content-desc='Ordenar por ']" })
        if sort_category_clickable && sort_category_clickable.displayed?
        else
          sort_category_clickable = nil
        end
      rescue
      end

      # Si no lo encontramos por content-desc, buscar por ID
      unless sort_category_clickable
        begin
          container = @driver.find_element({ id: 'selectable-21' })
          # Buscar el elemento clickable dentro del contenedor o usar el contenedor mismo
          begin
            sort_category_clickable = @driver.find_element({ xpath: "//android.view.View[@resource-id='selectable-21']//android.view.View[@content-desc='Ordenar por ']" })
            if sort_category_clickable && sort_category_clickable.displayed?
            else
              sort_category_clickable = nil
            end
          rescue
            # Si no encontramos el hijo, usar el contenedor mismo
            if container && container.displayed?
              sort_category_clickable = container
            end
          end
        rescue
        end
      end

      unless sort_category_clickable
        @logger.error("/// No se pudo encontrar el elemento 'Ordenar por'".colorize(:red))
        return false
      end

      # Paso 3: Hacer click en "Ordenar por" para abrir las opciones
      begin
        sort_category_clickable.click
        sleep(2) # Esperar a que se rendericen las opciones
      rescue => e
        @logger.error("/// Error al hacer click en 'Ordenar por': #{e.message}".colorize(:red))
        # Intentar click por coordenadas como fallback
        begin
          location = sort_category_clickable.location
          size = sort_category_clickable.size
          x = location.x + (size.width / 2)
          y = location.y + (size.height / 2)
          @driver.execute_script("mobile: tap", { x: x, y: y })
          sleep(2)
        rescue => e2
          @logger.error("/// Error al hacer click por coordenadas: #{e2.message}".colorize(:red))
          return false
        end
      end

      # Paso 4: Buscar y seleccionar la opción "Mayor precio"
      mayor_precio_locators = [
        { xpath: "//android.widget.ToggleButton[@text='Mayor precio']" },
        { xpath: "//android.view.View[@text='Mayor precio']" },
        { xpath: "//android.view.View[@content-desc='Mayor precio']" },
        { xpath: "//android.widget.TextView[@text='Mayor precio']" },
        { xpath: "//*[@text='Mayor precio']" },
        { id: 'sort-price_desc' },
        { xpath: "//android.view.View[@resource-id='sort-price_desc']" }
      ]

      mayor_precio_option = nil
      mayor_precio_locators.each do |locator|
        begin
          mayor_precio_option = @driver.find_element(locator)
          break
        rescue
        end
      end

      unless mayor_precio_option
        @logger.error("/// No se pudo encontrar la opción 'Mayor precio'".colorize(:red))
        return false
      end

      # Hacer click en "Mayor precio"
      begin
        mayor_precio_option.click
        sleep(1)
        @logger.info("==> Filtro 'Mayor precio' aplicado correctamente".colorize(:green))
        return true
      rescue => e
        @logger.error("/// Error al hacer click en 'Mayor precio': #{e.message}".colorize(:red))
        # Intentar click por coordenadas como fallback
        begin
          location = mayor_precio_option.location
          size = mayor_precio_option.size
          x = location.x + (size.width / 2)
          y = location.y + (size.height / 2)
          @driver.execute_script("mobile: tap", { x: x, y: y })
          sleep(1)
          return true
        rescue => e2
          @logger.error("/// Error al hacer click por coordenadas en 'Mayor precio': #{e2.message}".colorize(:red))
          return false
        end
      end

    rescue => e
      @logger.error("/// Error en apply_sort_filter: #{e.message}".colorize(:red))
      return false
    end
  end

  # Aplicar todos los filtros en orden: Condición, Envíos, Ordenar por
  def apply_all_filters
    # 1. Condición -> Nuevo (selectable-4) - Scroll hacia arriba
    unless apply_condition_filter
      return false
    end

    # 2. Envíos -> Local (selectable-9) - Scroll hacia arriba
    unless apply_shipping_filter
      return false
    end

    # 3. Ordenar por -> Mayor precio (selectable-21) - Scroll hacia abajo y aplicar filtro
    unless apply_sort_filter
      return false
    end

    return true
  end

  # Hacer click en el botón "Ver resultados" para aplicar los filtros
  def click_apply_filters_button
    begin
      sleep(1) # Esperar un momento para que el botón esté disponible

      # Buscar el botón "Ver resultados" usando múltiples localizadores
      apply_button_locators = [
        { xpath: "//android.widget.Button[@resource-id=':r3:']" },
        { id: ':r3:' },
        { xpath: "//android.widget.Button[contains(@text, 'Ver') and contains(@text, 'resultados')]" },
        { xpath: "//android.widget.Button[starts-with(@text, 'Ver')]" }
      ]

      apply_button = nil
      apply_button_locators.each do |locator|
        begin
          apply_button = @driver.find_element(locator)
          break
        rescue
        end
      end

      unless apply_button
        @logger.error("/// No se pudo encontrar el botón 'Ver resultados'".colorize(:red))
        return false
      end

      # Hacer click en el botón
      begin
        apply_button.click
        sleep(2) # Esperar a que se apliquen los filtros y se muestren los resultados
        return true
      rescue => e
        @logger.error("/// Error al hacer click en 'Ver resultados': #{e.message}".colorize(:red))
        # Intentar click por coordenadas como fallback
        begin
          location = apply_button.location
          size = apply_button.size
          x = location.x + (size.width / 2)
          y = location.y + (size.height / 2)
          @driver.execute_script("mobile: tap", { x: x, y: y })
          sleep(2)
          return true
        rescue => e2
          @logger.error("/// Error al hacer click por coordenadas: #{e2.message}".colorize(:red))
          return false
        end
      end

    rescue => e
      @logger.error("/// Error en click_apply_filters_button: #{e.message}".colorize(:red))
      return false
    end
  end

  # Extraer datos de un producto desde un elemento polycard_component
  def extract_product_data(product_element)
    begin
      product_data = {
        titulo: nil,
        precio: nil
      }

      # Buscar el título del artículo: el primer TextView dentro del card
      begin
        title_element = product_element.find_element({ xpath: ".//android.widget.TextView[1]" })
        if title_element
          product_data[:titulo] = title_element.text
        end
      rescue => e
        @logger.warn("   No se pudo extraer el título: #{e.message}".colorize(:yellow))
      end

      # Buscar el precio del artículo: buscar un hijo (o hijo de hijo) con resource-id="current amount"
      begin
        # Buscar directamente por resource-id="current amount"
        price_element = nil

        # Intentar buscar en hijos directos y nietos
        begin
          price_element = product_element.find_element({ xpath: ".//*[@resource-id='current amount']" })
        rescue
          # Si no se encuentra directamente, buscar en todos los descendientes
          begin
            price_element = product_element.find_element({ xpath: ".//android.view.View[@resource-id='current amount']" })
          rescue
            begin
              price_element = product_element.find_element({ xpath: ".//android.widget.TextView[@resource-id='current amount']" })
            rescue
            end
          end
        end

        if price_element
          # Obtener el content-desc del precio
          begin
            price_content_desc = price_element.attribute('content-desc')
            product_data[:precio] = price_content_desc
          rescue => e
            @logger.warn("   Precio encontrado pero no se pudo extraer el content-desc: #{e.message}".colorize(:yellow))
          end
        else
          @logger.warn("   No se encontró elemento con resource-id='current amount'".colorize(:yellow))
        end
      rescue => e
        @logger.warn("   No se pudo extraer el precio: #{e.message}".colorize(:yellow))
      end

      return product_data
    rescue => e
      @logger.error("/// Error al extraer datos del producto: #{e.message}".colorize(:red))
      return { titulo: nil, precio: nil }
    end
  end

  # Extraer los primeros 5 resultados de búsqueda
  def extract_first_5_results
    begin
      sleep(2) # Esperar a que se carguen los resultados
      products_data = []

      @logger.info("Extrayendo datos de los primeros 5 resultados...".colorize(:cyan))

      # Extraer los primeros 4 resultados (ya renderizados) usando xpath específicos
      (1..4).each do |index|
        begin
          # Usar xpath específico: (//android.view.View[@resource-id="polycard_component"])[index]
          product_xpath = "(//android.view.View[@resource-id='polycard_component'])[#{index}]"
          product_element = @driver.find_element({ xpath: product_xpath })

          product_data = extract_product_data(product_element)
          product_data[:numero] = index
          products_data << product_data

          @logger.info("   -> Producto #{index}: #{product_data[:titulo]} - #{product_data[:precio]}".colorize(:light_green))
        rescue => e
          @logger.warn("   ///  No se pudo extraer producto #{index}: #{e.message}".colorize(:yellow))
          products_data << { numero: index, titulo: nil, precio: nil }
        end
      end

      # Hacer scroll para renderizar el 5to resultado
      @driver.execute_script("mobile: swipeGesture", {
        "left" => 150,
        "top" => 1000,
        "width" => 1,
        "height" => 1100,
        "direction" => "up",
        "percent" => 1.0,
        "speed" => 500
      })
      sleep(2) # Esperar a que se renderice el nuevo producto

      # Extraer el 5to resultado usando xpath específico
      begin

        # Usar xpath específico: (//android.view.View[@resource-id="polycard_component"])[5]
        product_xpath = "(//android.view.View[@resource-id='polycard_component'])[5]"
        fifth_product = @driver.find_element({ xpath: product_xpath })

        product_data = extract_product_data(fifth_product)
        product_data[:numero] = 5
        products_data << product_data

        @logger.info("   -> Producto 5: #{product_data[:titulo]} - #{product_data[:precio]}".colorize(:light_green))
      rescue => e
        @logger.warn("   ///  No se pudo extraer producto 5: #{e.message}".colorize(:yellow))
        products_data << { numero: 5, titulo: nil, precio: nil }
      end

      return products_data

    rescue => e
      @logger.error("/// Error al extraer resultados: #{e.message}".colorize(:red))
      @logger.error("   Backtrace: #{e.backtrace.first(3).join("\n   ")}".colorize(:red))
      return []
    end
  end

  # Cerrar la sesión de Appium
  def close_session
    if @driver
      @driver.quit
    end
  end

  # Método principal para ejecutar el flujo completo
  def run
    # Iniciar sesión
    unless start_session
      @logger.error("/// No se pudo iniciar la sesión de Appium".colorize(:red))
      return false
    end

    # Abrir Mercado Libre
    unless open_mercado_libre
      @logger.error("/// No se pudo abrir Mercado Libre".colorize(:red))
      close_session
      return false
    end

    # Buscar "playstation 5"
    unless search_item("playstation 5")
      @logger.error("/// No se pudo realizar la búsqueda".colorize(:red))
      close_session
      return false
    end

    # Abrir filtros
    unless click_filters_button
      @logger.error("/// No se pudo abrir los filtros".colorize(:red))
      close_session
      return false
    end

    # Aplicar todos los filtros
    unless apply_all_filters
      @logger.error("/// No se pudieron aplicar todos los filtros".colorize(:red))
      close_session
      return false
    end

    # Hacer click en el botón "Ver resultados" para aplicar los filtros
    unless click_apply_filters_button
      @logger.error("/// No se pudo hacer click en el botón 'Ver resultados'".colorize(:red))
      close_session
      return false
    end

    # Extraer datos de los primeros 5 resultados
    products_data = extract_first_5_results
    unless products_data && products_data.length > 0
      @logger.warn("/// No se pudieron extraer datos de los productos".colorize(:yellow))
      # Continuar aunque no se hayan extraído datos
    end

    # Almacenar los datos extraídos (puedes guardarlos en un archivo o procesarlos aquí)
    @products_data = products_data

    # Cerrar sesión
    close_session
    return true
  end
end

# Ejecutar el script si se llama directamente
if __FILE__ == $0
  app_opener = MercadoLibreAppOpener.new
  success = app_opener.run

  if success
    exit(0)
  else
    exit(1)
  end
end
